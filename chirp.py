import traceback

import pg
db=pg.DB(dbname='chirp')

import bcrypt

from flask import Flask, render_template, request, redirect, session

app = Flask('MyApp')

def quoted(s):
    return "'" + s + "'"

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

    # query1 = db.query("select user_id, handle, fname, lname, num_chirps, num_following, num_being_followed from v_chirp_follow_summary where user_id=1;")
    sql1 = "select user_id, handle, fname, lname, num_chirps, num_following, num_being_followed from v_chirp_follow_summary where handle='" + session['userid'] + "'"

    query1 = db.query(sql1)
    print "postgreSQL..."
    print sql1
    print query1
    print query1.namedresult()
    print query1.dictresult()[0]['handle']
    # new_userid = query.dictresult()[0]['id']


    sql2 = "select chirper_id, fname, lname, handle, chirp_date, chirp from chirps join users on chirper_id = users.id where handle='" + session['userid'] + "' order by chirp_date desc;"
    query2 = db.query(sql2)
    return render_template('profile.html', title='Profile', profile_rows=query1.namedresult(), chirp_rows=query2.namedresult())

@app.route('/timeline')
def timeline():
    query1 = db.query("select chirper_id, chirp_date, chirp, fname, lname, handle from chirps left join users on chirper_id = users.id where chirper_id in (select leader_id from follows where follower_id = 4) or chirper_id = 4 order by chirp_date desc;")
    return render_template('timeline.html', title='Timeline', profile_rows=query1.namedresult(), timeline_rows=query1.namedresult())

@app.route('/login')
def login():
    return render_template(
    'login.html',
    title='Login')

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

    sql = "select * from users where handle = '" + userid + "';"
    query = db.query(sql)

    print query.namedresult()
    print len(query.namedresult())

    if len(query.namedresult()) == 0:
        print "user does not exist"
        return redirect('/login')
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

    sql2 = "insert into chirps (chirper_id, chirp) values(" + str(userid) + ", " + quoted(new_chirp) + ");"
    print 'sql2 = ' + sql2
    db.query(sql2)
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
        sql = "select handle from users where handle = '" + userid + "'"
        print sql
        query = db.query(sql)
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

            #create a chirp at signing
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



# the test rouute was only used to encrypt passwords of users whose passwords were not already encrypted
# @app.route('/test')
# def test():
#
#     def quoted(s):
#         return "'" + s + "'"
#
#     comma = ","
#
#     sql = "select * from users;"
#     query = db.query(sql)
#     print query.namedresult()
#
#     for user in query.namedresult():
#         password =  user.password
#         encrypted_pw = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
#         print user.handle
#         print password
#         print encrypted_pw
#         print "----------------------"
#         # update users set password = 'xxx' where id=24;
#         sql = "update users set password = " + quoted(encrypted_pw) + " where handle = " + quoted(user.handle)
#         print sql
#         db.query(sql)
#
#     return render_template(
#     'tryagain.html',
#     title='Create User')
#   return redirect('/login')


# ------------------------------------------------------------------------------------------------- #
# @app.route('/add', methods=['POST'])
# def add():
#     newtask = request.form['newtask']
#     sql_str = "insert into tasks (task) values ('" + newtask + "');"
#     print sql_str
#     db.query(sql_str)
#     return redirect('/')
#
# @app.route('/complete', methods=['POST'])
# def complete():
#     my_tasks = request.form
#     print "tasks"
#     print my_tasks
#
#     # need to find out if it is complete or delete
#
#     for t in my_tasks:
#         if t == "complete":
#             mode = "complete"
#         elif t == "delete":
#             mode = "delete"
#
#     print mode
#
#     if mode == "complete":
#         for t in my_tasks:
#             # print "task"
#             # print t
#             sql = "update tasks set complete=true where id=" + t
#             # print "sql"
#             # print sql
#             if t != "complete":
#                 db.query(sql)
#
#     if mode == "delete":
#         for t in my_tasks:
#             print "task"
#             print t
#             sql = "delete from tasks where id=" + t
#             print "sql"
#             print sql
#             if t != "delete":
#                 db.query(sql)
#
#     return redirect('/')

app.secret_key = 'CSF686CCF85C6FRTCHQDBJDXHBHC1G478C86GCFTDCR'

app.debug = True

if __name__ == '__main__':
     app.run(debug=True)
