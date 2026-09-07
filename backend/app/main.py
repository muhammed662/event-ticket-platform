from contextlib import asynccontextmanager
from datetime import UTC, datetime, timedelta

from fastapi import Depends, FastAPI
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.database import Base, SessionLocal, engine, get_database
from app.models import Event
from app.schemas import EventResponse

def future_date(days_from_now: int, hour: int) -> datetime:
    current_time = datetime.now(UTC)

    return (
        current_time + timedelta(days=days_from_now)
    ).replace(
        hour=hour,
        minute=0,
        second=0,
        microsecond=0,
        tzinfo=None,
    )


def seed_events():
    with SessionLocal() as database:
        existing_event_id = database.scalar(
            select(Event.id).limit(1)
        )

        if existing_event_id is not None:
            return

        events = [
            Event(
                title="Dubai Music Night",
                venue="City Events Hall",
                city="Dubai",
                starts_at=future_date(14, 20),
                price_aed=125,
                ticket_capacity=100,
                tickets_remaining=100,
            ),
            Event(
                title="Technology Meetup",
                venue="Innovation Centre",
                city="Dubai",
                starts_at=future_date(21, 18),
                price_aed=50,
                ticket_capacity=60,
                tickets_remaining=60,
            ),
            Event(
                title="Comedy Showcase",
                venue="Downtown Theatre",
                city="Dubai",
                starts_at=future_date(28, 19),
                price_aed=80,
                ticket_capacity=80,
                tickets_remaining=80,
            ),
        ]

        database.add_all(events)
        database.commit()


@asynccontextmanager
async def lifespan(_: FastAPI):
    Base.metadata.create_all(bind=engine)
    seed_events()

    yield

app = FastAPI(
    title="Event Ticket API",
    version="1.0.0",
    lifespan=lifespan,

)


@app.get("/api/health")
def health_check():
    return {"status": "healthy"}

@app.get("/api/events", response_model=list[EventResponse])
def list_events(
    database: Session = Depends(get_database),
):
    query = select(Event).order_by(Event.starts_at)

    return database.scalars(query).all()