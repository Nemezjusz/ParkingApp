FROM python:3.9

WORKDIR /code

COPY ./requirements.txt /code/requirements.txt

RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

COPY ./app /code/app

# CMD ["fastapi", "run", "app/server.py", "--proxy-headers", "--port", "8000"]
CMD ["sh", "-c", "python app/manage_users.py add mateusz test@sp.pl mati12345 --admin && python app/manage_parking.py add free green && python app/server.py"]

