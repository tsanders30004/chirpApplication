import traceback

import pg
db=pg.DB(dbname='chirp')

import bcrypt

from flask import Flask, render_template, request, redirect, session

app = Flask('MyApp')

def quoted(s):
    return "'" + s + "'"

def quoted_percent(s):
    return "'%" + s + "%'"

def like_percent(s):
    return "%" + s + "%"

comma = ","

@app.route('/')
def home():
    try:
        print session['userid']
        return redirect('/profile')
    except Exception, e:
        print "not logged in"
        return redirect('/login')

@app.route('/profile')
def profile():

    # is user logged in?
    if len(session['userid']) == 0:
        # user is not logged in; reroute.
        return render_template('login.html', title='Login')

    sql1 = "select user_id, handle, fname, lname, num_chirps, num_following, num_being_followed from v_chirp_follow_summary where handle='" + session['userid'] + "'"

    query1 = db.query(sql1)

    # sql2 = "select chirper_id, fname, lname, handle, chirp_date, chirp from chirps join users on chirper_id = users.id where handle='" + session['userid'] + "' order by chirp_date desc;"
    sql2 = "select chirper_id, fname, lname, handle, to_char(chirp_date, 'MM/DD/YYYY: ') as chirp_date, chirp from chirps join users on chirper_id = users.id where handle='" + session['userid'] + "' order by chirp_date desc;"
    query2 = db.query(sql2)

    return render_template('profile.html', title='Profile', profile_rows=query1.namedresult(), chirp_rows=query2.namedresult())

@app.route('/timeline')
def timeline():
    # is user logged in?
    if len(session['userid']) == 0:
        # user is not logged in; reroute.
        return render_template('login.html', title='Login')

    query1 = db.query("select chirper_id, chirp_date, chirp, fname, lname, handle from chirps left join users on chirper_id = users.id where chirper_id in (select leader_id from follows where follower_id = 4) or chirper_id = 4 order by chirp_date desc;")
    return render_template('timeline.html', title='Timeline', profile_rows=query1.namedresult(), timeline_rows=query1.namedresult())

@app.route('/login')
def login():
    return render_template('login.html', title='Login')

@app.route('/logout')
def logout():
    session['userid'] = ""
    return render_template('login.html', title='Login')

@app.route('/signup')
def signup():
    return render_template(
    'signup.html',
    title='Sign Up')

@app.route('/check_pw', methods=['POST'])
def check_password():
    userid = request.form['userid']
    password = request.form['password']
    print userid + ' tried to login with password ' + password

    sql = "select * from users where handle = $1"
    query = db.query(sql, userid)

    print query.namedresult()
    print len(query.namedresult())

    if len(query.namedresult()) == 0:
        print "user does not exist"
        return redirect('/signup')
    else:
        print "user does exist"
        for user in query.namedresult():
            print 'encrypted password = ' + user.password
            if bcrypt.hashpw(password.encode('utf-8'), user.password) == user.password:
                print "encrypted password was correct"
                session['userid'] = userid
                return redirect('/profile')
            else:
                print "encrypted password was not correct"
                return render_template(
                'badlogin.html',
                title='Incorrect Login')

    # try:
    #     session['userid'] = userid
    #     # return render_template('proj_summary.html', title='Login Status', userdata=query.namedresult())
    #     return redirect('/profile')
    # except Exception, e:
    #     print traceback.format_exc()
    #     return "Error %s" % traceback.format_exc()

@app.route('/new_chirp', methods=['POST'])
def new_chirp():
    new_chirp = request.form['new_chirp']
    print session['userid']

    print 'new chirp = ' + new_chirp;
    print 'logged in user = ' + session['userid']

    sql1 = "select id from users where handle = " + quoted(session['userid']) + ";"
    print sql1
    userid = db.query(sql1).dictresult()[0]["id"]
    print userid

    # sql2 = "insert into chirps (chirper_id, chirp) values(" + str(userid) + ", " + quoted(new_chirp) + ");"
    sql2 = "insert into chirps (chirper_id, chirp) values($1, $2)"

    print 'sql2 = ' + sql2
    db.query(sql2, str(userid), new_chirp)
    return redirect('/timeline')

@app.route('/create_user', methods=['POST'])
def create_user():
    def quoted(s):
        return "'" + s + "'"
    comma = ","
    try:
        userid = request.form['userid']
        password = request.form['password']
        fname = request.form['fname']
        lname = request.form['lname']
        print 'userid = ' + userid
        print 'password = ' + password
        # check to see if user id already exists
        # sql = "select handle from users where handle = '" + userid + "'"
        sql = "select handle from users where handle = $1"
        print sql
        query = db.query(sql, userid)
        print query.namedresult()
        print len(query.namedresult())

        if len(query.namedresult()) == 1:
            print "that userid is already taken"
            # need to redirect user to an error page
            return render_template(
            'tryagain.html',
            title='Create User')
        else:
            # need to create the new user and direct the user to login

            # try to encrypt the password
            binary_pw = password.encode('utf-8')
            hashed = bcrypt.hashpw(binary_pw, bcrypt.gensalt())
            print hashed

            print "that userid is ok; adding to the database"
            sql = "insert into users (handle, fname, lname, password) values (" + quoted(userid) + comma + quoted(fname) + comma + quoted(lname) + comma + quoted(hashed) + ");"
            print sql
            query = db.query(sql)

            #create a chirp at signin
            sql = "select id from users where handle = " + quoted(userid) + ";"
            print sql

            query = db.query(sql)

            new_userid = query.dictresult()[0]['id']

            print "new user id = "
            print new_userid

            # sql = "insert into chirps (chirper_id, chirp) values (" + to_char(   new_userid + ", 'Joined Chirp Today!')"
            # print sql
            sql2 = "xxx" + str(39) + "yyy"
            print sql2

            sql = "insert into chirps (chirper_id, chirp) values (" + str(new_userid) + ", 'Welcome me to Chirp!')"
            print sql
            db.query(sql)

            # print "new user id = " + user_id
            return redirect('/login')

    except Exception, e:
        print "something went wrong in /create_user route."
        print traceback.format_exc()
        return "Error %s" % traceback.format_exc()
        return redirect('/login')

@app.route('/search', methods=['POST'])
def search():
    search_list = request.form['search_str'].split()

    print session['userid']

    userid = session['userid']

    sql1 = "DROP TABLE " + session['userid']
    sql2 = 'CREATE TABLE "public"."' + userid + '" ("handle" varchar, "name" varchar, "chirp" varchar)'
    print sql1
    print sql2

    db.query('DROP TABLE temp')
    db.query('CREATE TABLE "public"."temp" ("handle" varchar, "name" varchar, "chirp" varchar)')

    for n in range(len(search_list)):
        print n

        sql1 = "insert into temp select handle, fname || ' ' || lname as name, chirp from users left join chirps on users.id = chirps.chirper_id where lower(fname) like $1 or lower(lname) like $1 or lower(handle) like $1 or lower(chirp) like $1"

        search_results = db.query(sql1, like_percent(search_list[n].lower()))

        sql2 = "select distinct * from temp;"
        search_results = db.query(sql2)

    # print search_results
    return render_template('search_results.html', title='Show Search Results', search_results = search_results.namedresult())


@app.route('/add_follow', methods=['POST'])
def add_follow():

    user_to_follow = request.form['user_to_follow']
    print user_to_follow

    logged_in_user = session['userid']
    print logged_in_user

    sql = "insert into follows (follower_id, leader_id) values ((select id from users where users.handle = " + quoted(logged_in_user)+ "), (select id from users where users.handle = " + quoted(user_to_follow)+ "));"
    print sql

    try:
        db.query(sql)
        print "follow table was updated"
        return redirect('/profile')
    except Exception, e:
        print "unique constraint violated; follow table not updated"
        return redirect('/profile')

app.secret_key = 'CSF686CCF85C6FRTCHQDBJDXHBHC1G478C86GCFTDCR'

app.debug = True

if __name__ == '__main__':
     app.run(debug=True)
