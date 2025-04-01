from fastapi import FastAPI, Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer
from fastapi.templating import Jinja2Templates
from sqlalchemy.orm import Session
from starlette.requests import Request
from app.database import engine, SessionLocal
from app import models, schemes, auth, crud
#import logging

app = FastAPI()

templates = Jinja2Templates(directory="app/templates")

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

models.Base.metadata.create_all(bind=engine)

#logger = logging.getLogger(__name__)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.get("/")
async def login_page(request: Request):
    return templates.TemplateResponse("login.html", {"request": request})

@app.get("/register")
async def register_page(request: Request):
    return templates.TemplateResponse("register.html", {"request": request})

@app.post("/register", response_model=schemes.UserOut)
def register_user(user: schemes.UserCreate, db: Session = Depends(get_db)):
    db_user = crud.get_user_by_username(db, username=user.username)
    if db_user is None:
        raise HTTPException(status_code=400, detail="Username already exists")
    return db_user

@app.post("/token", response_model=schemes.Token)
def login_for_access_token(user: schemes.UserCreate, db: Session = Depends(get_db)):
    user_db = crud.authenticate_user(db, user.username, user.password)
    if not user_db:
        raise HTTPException(status_code=401)


