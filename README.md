
````
git clone https://github.com/mohamadfajim/serverTraffic

````

````
cd serverTraffic

````

````
apt update && apt install python3 python3-pip python-is-python3

````

````
pip install -r requirements.txt

````

````
pip install gunicorn

````

````
pip install python-dotenv

````

````
gunicorn --bind 0.0.0.0:8000 wsgi:app

````

ادرس ایپی :‌۸۰۰۰ را در مرورگر باز میکنیم اگر صفحه باز شد کنترل + سی را میزنیم و بعد دستور زیر 




````
nohup gunicorn --bind 0.0.0.0:8000 wsgi:app &

````

