from datetime import datetime

from pydantic import BaseModel, Field


class EventResponse(BaseModel):
    id: int
    title: str
    venue: str
    city: str
    starts_at: datetime
    price_aed: int = Field(gt=0)
    ticket_capacity: int = Field(gt=0)
    tickets_remaining: int = Field(ge=0)