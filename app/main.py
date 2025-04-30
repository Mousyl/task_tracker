from fastapi import FastAPI, Depends, HTTPException, Form, Request, status
from fastapi.security import OAuth2PasswordBearer
from fastapi.templating import Jinja2Templates
from fastapi.staticfiles import StaticFiles
from sqlalchemy.orm import Session
from starlette.requests import Request
from starlette.responses import RedirectResponse
from app.database import engine, SessionLocal
from app import models, schemes, auth, crud
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI()

# Mount static files
app.mount("/static", StaticFiles(directory="app/static"), name="static")

# Configure templates
templates = Jinja2Templates(directory="app/templates")

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

models.Base.metadata.create_all(bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.get("/healthz")
def healthz():
    return {"status": "ok"}

@app.get("/")
async def root(request: Request):
    logger.info("Root endpoint accessed")
    return templates.TemplateResponse("login.html", {"request": request})

@app.get("/login")
async def login_page(request: Request):
    logger.info("Login page accessed")
    return templates.TemplateResponse("login.html", {"request": request})

@app.get("/register")
async def register_page(request: Request):
    logger.info("Register page accessed")
    return templates.TemplateResponse("register.html", {"request": request})

@app.post("/register")
async def register_user(
    request: Request,
    username: str = Form(...),
    password: str = Form(...),
    db: Session = Depends(get_db)
):
    logger.info(f"Attempting to register user: {username}")
    db_user = crud.get_user_by_username(db, username=username)
    if db_user:
        raise HTTPException(status_code=400, detail="Username already exists")
    
    user = schemes.UserCreate(username=username, password=password)
    created_user = crud.create_user(db=db, user=user)
    
    return templates.TemplateResponse("success.html", {"request": request, "username": username})

@app.post("/token")
async def login_for_access_token(
    username: str = Form(...),
    password: str = Form(...),
    db: Session = Depends(get_db)
):
    logger.info(f"Login attempt for user: {username}")
    user_db = crud.authenticate_user(db, username, password)
    if not user_db:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    access_token = auth.create_access_token(data={"sub": username})
    response = RedirectResponse(url="/dashboard", status_code=status.HTTP_302_FOUND)
    response.set_cookie(key="access_token", value=f"Bearer {access_token}")
    return response

@app.get("/dashboard")
async def dashboard(request: Request, db: Session = Depends(get_db)):
    logger.info("Dashboard accessed")
    token = request.cookies.get("access_token")
    if not token:
        return RedirectResponse(url="/login", status_code=status.HTTP_302_FOUND)
    
    try:
        token = token.split(" ")[1]
        payload = auth.decode_token(token)
        username = payload.get("sub")
        if not username:
            return RedirectResponse(url="/login", status_code=status.HTTP_302_FOUND)
        
        return templates.TemplateResponse("dashboard.html", {"request": request, "username": username})
    except Exception:
        return RedirectResponse(url="/login", status_code=status.HTTP_302_FOUND)

