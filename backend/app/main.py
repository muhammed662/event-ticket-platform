from fastapi import FastAPI


app = FastAPI(
    title="Event Ticket API",
    version="1.0.0",
)

@app.get("/api/health")
def health_check():
    return {"status": "healthy"}