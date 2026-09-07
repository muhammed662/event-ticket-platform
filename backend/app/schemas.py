from datetime import datetime
from pydantic import BaseModel, ConfigDict, Field, field_validator


class EventResponse(BaseModel):
    model_config = ConfigDict(
        from_attributes=True,
    )
    id: int
    title: str
    venue: str
    city: str
    starts_at: datetime
    price_aed: int = Field(gt=0)
    ticket_capacity: int = Field(gt=0)
    tickets_remaining: int = Field(ge=0)

class BookingCreate(BaseModel):
    event_id: int = Field(gt=0)

    customer_name: str = Field(
        max_length=120,
    )

    customer_email: str = Field(
        max_length=255,
    )

    quantity: int = Field(
        ge=1,
        le=6,
    )

    @field_validator("customer_name")
    @classmethod
    def validate_customer_name(cls, value: str) -> str:
        cleaned_name = " ".join(value.split())

        if len(cleaned_name) < 2:
            raise ValueError(
                "Customer name must contain at least 2 characters"
            )

        return cleaned_name

    @field_validator("customer_email")
    @classmethod
    def validate_customer_email(cls, value: str) -> str:
        cleaned_email = value.strip().lower()

        if (
            "@" not in cleaned_email
            or "." not in cleaned_email.rsplit("@", 1)[-1]
        ):
            raise ValueError("Enter a valid email address")

        return cleaned_email    
class BookingEventResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    title: str
    venue: str
    city: str
    starts_at: datetime    

class BookingResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    booking_reference: str
    event_id: int
    customer_name: str
    customer_email: str
    quantity: int
    total_aed: int
    status: str
    created_at: datetime
    event: BookingEventResponse    