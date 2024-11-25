FROM python:3.9

WORKDIR /code

COPY ./requirements.txt /code/requirements.txt

RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

COPY ./app /code/app

# CMD ["fastapi", "run", "app/server.py", "--proxy-headers", "--port", "8000"]
CMD ["sh", "-c", "python app/manage_users.py add mateusz mateusz test@sp.pl mati12345 --admin && python app/manage_parking.py add free green 1 2 && python app/manage_parking.py add free green 1 1 && python app/manage_parking.py add free green 1 3 && python app/manage_parking.py add free green 1 4 && python app/manage_parking.py add free green 1 5 && python app/manage_parking.py add free green 1 6 && python app/manage_parking.py add free green 1 7 && python app/manage_parking.py add free green 1 8 && python app/manage_parking.py add free green 1 9 && python app/manage_parking.py add free green 1 10 && python app/manage_parking.py add free green 1 11 && python app/manage_parking.py add free green 1 12 && python app/manage_parking.py add free green 1 13 && python app/manage_parking.py add free green 1 14 && python app/manage_parking.py add free green 1 15 && python app/manage_parking.py add free green 1 16 && python app/manage_parking.py add free green 1 17 && python app/manage_parking.py add free green 1 18 && python app/manage_parking.py add free green 1 19 && python app/manage_parking.py add free green 1 20 && python app/server.py"]
