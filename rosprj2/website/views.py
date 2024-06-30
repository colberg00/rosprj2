from flask import Blueprint, render_template, request, flash, jsonify
from .models import sURL
from . import db
from flask_login import login_required, current_user
import json


views = Blueprint('views', __name__)

@views.route('/', methods=['GET', 'POST'])
@login_required
def home():
    if request.method == 'POST':
        url = request.form.get('url')

        if len(url) < 4:
            flash('URL is to short', category='error')
        else:
            new_url = sURL(data=url, user_id=current_user.id)
            db.session.add(new_url)
            db.session.commit()
            flash('URL is added to database!', category='succes')

    return render_template("home.html", user=current_user)

@views.route('/delete-url', methods=['POST'])
def delete_url():  
    url = json.loads(request.data) # this function expects a JSON from the INDEX.js file 
    urlId = url['urlId']
    url = sURL.query.get(urlId)
    if url:
        if url.user_id == current_user.id:
            db.session.delete(url)
            db.session.commit()

    return jsonify({})

@views.route('/fetch_approved_urls', methods=['GET'])
def fetch_approved_urls():
    all_urls = sURL.query.all()  # Fetch all records from the sURL model
    url_list = [url.data for url in all_urls]  # Extract the URL from each record
    return jsonify(url_list)  # Return the list of URLs as JSON
