const isLocalDevelopment = [
    "127.0.0.1",
    "localhost",
].includes(window.location.hostname);

const API_BASE_URL = isLocalDevelopment
    ? "http://127.0.0.1:8000"
    : "";

const eventsList = document.querySelector("#events-list");
const eventsMessage = document.querySelector("#events-message");
const eventSelect = document.querySelector("#event-id");


async function loadEvents() {
    eventsMessage.textContent = "Loading events...";

    try {
        const response = await fetch(
            `${API_BASE_URL}/api/events`
        );

        if (!response.ok) {
            throw new Error("The server could not load events.");
        }

        const events = await response.json();

        eventsList.replaceChildren();

        eventSelect.replaceChildren(
            new Option("Select an event", "")
        );

        if (events.length === 0) {
            eventsMessage.textContent =
                "There are currently no available events.";

            return;
        }

        eventsMessage.textContent = "";

        for (const event of events) {
            displayEvent(event);
            addEventOption(event);
        }
    } catch (error) {
        eventsMessage.textContent =
            "Events could not be loaded. Please try again.";
    }
}


function displayEvent(event) {
    const card = document.createElement("article");

    const title = document.createElement("h3");
    title.textContent = event.title;

    const location = document.createElement("p");
    location.textContent = `${event.venue}, ${event.city}`;

    const date = document.createElement("p");
    date.textContent = event.starts_at.replace("T", " ");

    const price = document.createElement("p");
    price.textContent = `AED ${event.price_aed} per ticket`;

    const availability = document.createElement("p");
    availability.textContent =
        `${event.tickets_remaining} tickets remaining`;

    card.append(
        title,
        location,
        date,
        price,
        availability
    );

    eventsList.append(card);
}


function addEventOption(event) {
    if (event.tickets_remaining === 0) {
        return;
    }

    const option = new Option(
        `${event.title} — AED ${event.price_aed}`,
        event.id
    );

    eventSelect.add(option);
}


loadEvents();

const bookingForm =
    document.querySelector("#booking-form");

const bookingResult =
    document.querySelector("#booking-result");


bookingForm.addEventListener(
    "submit",
    createBooking
);


async function createBooking(submitEvent) {
    submitEvent.preventDefault();

    const submitButton =
        bookingForm.querySelector("button[type='submit']");

    const bookingData = {
        event_id: Number(eventSelect.value),

        customer_name: document
            .querySelector("#customer-name")
            .value,

        customer_email: document
            .querySelector("#customer-email")
            .value,

        quantity: Number(
            document.querySelector("#quantity").value
        ),
    };

    bookingResult.textContent = "Creating booking...";
    submitButton.disabled = true;

    try {
        const response = await fetch(
            `${API_BASE_URL}/api/bookings`,
            {
                method: "POST",

                headers: {
                    "Content-Type": "application/json",
                },

                body: JSON.stringify(bookingData),
            }
        );

        const responseData = await response.json();

        if (!response.ok) {
            throw new Error(
                getErrorMessage(responseData)
            );
        }

        bookingResult.textContent =
            `Booking confirmed. Reference: ` +
            `${responseData.booking_reference}. ` +
            `Total: AED ${responseData.total_aed}.`;

        bookingForm.reset();

        await loadEvents();
    } catch (error) {
        bookingResult.textContent = error.message;
    } finally {
        submitButton.disabled = false;
    }
}


function getErrorMessage(responseData) {
    if (typeof responseData.detail === "string") {
        return responseData.detail;
    }

    if (Array.isArray(responseData.detail)) {
        return responseData.detail
            .map((error) => error.msg)
            .join(", ");
    }

    return "The booking could not be completed.";
}