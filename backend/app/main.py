from contextlib import asynccontextmanager
from datetime import datetime, timedelta, timezone
from uuid import uuid4

from fastapi import Depends, FastAPI, HTTPException, Query, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import select, update
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session, selectinload

from app.database import Base, SessionLocal, engine, get_database
from app.models import Booking, Event
from app.schemas import BookingCreate, BookingResponse, EventResponse

def future_date(days_from_now: int, hour: int) -> datetime:
    current_time = datetime.now(timezone.utc)

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
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://127.0.0.1:5500",
        "http://localhost:5500",
    ],
    allow_credentials=False,
    allow_methods=["GET", "POST"],
    allow_headers=["Content-Type"],
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

@app.post(
    "/api/bookings",
    response_model=BookingResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_booking(
    booking_data: BookingCreate,
    database: Session = Depends(get_database),
):
    event = database.get(Event, booking_data.event_id)

    if event is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Event not found",
        )

    current_time = datetime.now(timezone.utc).replace(tzinfo=None)

    if event.starts_at <= current_time:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="This event has already started",
        )

    inventory_update = database.execute(
        update(Event)
        .where(
            Event.id == booking_data.event_id,
            Event.tickets_remaining >= booking_data.quantity,
        )
        .values(
            tickets_remaining=(
                Event.tickets_remaining - booking_data.quantity
            )
        )
    )

    if inventory_update.rowcount != 1:
        database.rollback()

        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Not enough tickets available",
        )

    booking = Booking(
        booking_reference=f"TKT-{uuid4().hex[:8].upper()}",
        event_id=event.id,
        customer_name=booking_data.customer_name,
        customer_email=booking_data.customer_email,
        quantity=booking_data.quantity,
        total_aed=event.price_aed * booking_data.quantity,
        status="confirmed",
    )

    database.add(booking)

    try:
        database.commit()
        database.refresh(booking)
    except SQLAlchemyError:
        database.rollback()

        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="The booking could not be completed",
        )

    return booking

@app.get(
    "/api/bookings",
    response_model=list[BookingResponse],
)
def find_bookings(
    email: str = Query(min_length=5, max_length=255),
    database: Session = Depends(get_database),
):
    cleaned_email = email.strip().lower()

    query = (
        select(Booking)
        .options(selectinload(Booking.event))
        .where(Booking.customer_email == cleaned_email)
        .order_by(Booking.created_at.desc())
    )

    return database.scalars(query).all()