from flask import Flask
from datetime import datetime

# Redis Python Client
# https://github.com/andymccurdy/redis-py
import redis

application = Flask(__name__)

# Flask Session
# https://pythonhosted.org/Flask-Session/
redis_obj = redis.StrictRedis(host='redis', port=6379, db=0)



@application.route("/")
def hello():
    redis_key = 'visit_number'
    visit_number = 1

    if redis_obj.exists(redis_key):
        visit_number = int(redis_obj.get(redis_key).decode("utf-8")) + 1

    redis_obj.set(redis_key, visit_number)

    return "<h1 style='color:blue'>Hello There! This is your visit #{0}</h1>".format(visit_number)

if __name__ == '__main__':
    application.run(debug=True)
