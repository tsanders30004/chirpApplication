import traceback

import pg
db=pg.DB(dbname='chirp')

from flask import Flask, render_template, request, redirect, session

app = Flask('MyApp')

@app.route('/profile')
def profile():
    query1 = db.query("select user_id, handle, fname, lname, num_chirps, num_following, num_being_followed from v_chirp_follow_summary where user_id=1;")
    query2 = db.query("select chirper_id, fname, lname, handle, chirp_date, chirp from chirps join users on chirper_id = users.id where chirper_id = 1 order by chirp_date desc;")
    return render_template('profile.html', title='Profile', profile_rows=query1.namedresult(), chirp_rows=query2.namedresult())

@app.route('/timeline')
def timeline():
    query1 = db.query("select chirper_id, chirp_date, chirp, fname, lname, handle from chirps left join users on chirper_id = users.id where chirper_id in (select leader_id from follows where follower_id = 4) or chirper_id = 4 order by chirp_date desc;")
    return render_template('timeline.html', title='Timeline', profile_rows=query1.namedresult(), timeline_rows=query1.namedresult())

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



app.debug = True

if __name__ == '__main__':
     app.run(debug=True)
