from fastapi import FastAPI

from datetime import UTC, datetime, timedelta

from app.schemas import EventResponse


app = FastAPI(
    title="Event Ticket API",
    version="1.0.0",

)

sample_events = [
    EventResponse(
        id=1,
        title="Dubai Music Night",
        venue="City Events Hall",
        city="Dubai",
        starts_at=datetime.now(UTC) + timedelta(days=14),
        price_aed=125,
        ticket_capacity=100,
        tickets_remaining=100,
    ),
    EventResponse(
        id=2,
        title="Technology Meetup",
        venue="Innovation Centre",
        city="Dubai",
        starts_at=datetime.now(UTC) + timedelta(days=21),
        price_aed=50,
        ticket_capacity=60,
        tickets_remaining=60,
    ),
]

@app.get("/api/health")
def health_check():
    return {"status": "healthy"}

@app.get("/api/events", response_model=list[EventResponse])
def list_events():
    return sample_events