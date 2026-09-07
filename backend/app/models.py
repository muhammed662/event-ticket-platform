from datetime import datetime

from sqlalchemy import DateTime, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base


class Event(Base):
    __tablename__ = "events"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
    )

    title: Mapped[str] = mapped_column(
        String(150),
        nullable=False,
    )

    venue: Mapped[str] = mapped_column(
        String(150),
        nullable=False,
    )

    city: Mapped[str] = mapped_column(
        String(80),
        nullable=False,
    )

    starts_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False,
        index=True,
    )

    price_aed: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
    )

    ticket_capacity: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
    )

    tickets_remaining: Mapped[int] = mapped_column(
        Integer,
        nullable=False,
    )