# michael_nauman

require 'sinatra'
require 'sinatra/reloader'
require "better_errors"
require 'pry'
require 'pg'

# include the BetterErrors middleware
configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = __dir__
end

# ---- config ----

set :conn, PG.connect(dbname: 'squadslab')

before do
  @conn = settings.conn
end

# ---- ROUTES ----

#ROOT
# this is the route route
get '/' do
 redirect '/squads'
end 

# Your app should have the following GET routes.

#INDEX
# /squads - this route takes the user to a page that shows all of the squads
get '/squads' do
  squads = []
  @conn.exec("SELECT * FROM squads ORDER BY name ASC") do |result|
    result.each do |squad|
      squads << squad
    end
  end
  @squads = squads
  erb :index
end

# NEWSQUAD
# /squads/new - this route takes the user to a page with a form that allows them to create a new squad
get '/squads/new' do
  erb :newsquad
end

# SHOWSQUAD
# /squads/:squad_id - this route takes the user to a page that shows information about a single squad
get '/squads/:id' do
  id = params[:id].to_i
  squad = @conn.exec("SELECT * FROM squads WHERE id = $1", [id])
  @id = id
  @squad = squad[0]
  erb :showsquad
end

# SQUADMEMBERS
# /squads/:squad_id/students - this route takes the user to a page that shows all of the students for an individual squad
get '/squads/:squad_id/students' do
  squad_id = params[:squad_id].to_i
  squadmembers = []
  @conn.exec("SELECT * FROM squads JOIN students ON squads.id = students.squadid where squads.id = $1", [squad_id]) do |result|
    result.each do |squad|
      squadmembers << squad
    end  
  end
  binding.pry
  @squadmembers = squadmembers 
  @squad_id = squad_id
  erb :squadmembers
end

# EDITSQUAD
# /squads/:squad_id/edit - this route takes the user to a page with a form that allows them to edit an existing squad
get '/squads/:id/edit' do
  id = params[:id].to_i
  squad = @conn.exec("SELECT * FROM squads WHERE id = $1", [id])
  @squad = squad[0]
  erb :editsquad
end

#SHOWSTUDENT
# /squads/:squad_id/students/:student_id - this route takes the user to a page that shows information about an individual student in a squad
get '/squads/:squad_id/students/:student_id' do
  squad_id = params[:squad_id].to_i
  student_id = params[:student_id].to_i
  student = @conn.exec("SELECT * FROM squads JOIN students ON squads.id = students.squadid where squads.id = $1 AND students.id = $2", [squad_id, student_id])
  @squad_id = squad_id
  @student_id = student_id
  @student = student[0]
  erb :showstudent
end

#NEWSTUDENT
# /squads/:squad_id/students/new - this route takes the user to a page that shows them a form to create a new student
get '/squads/:id/newstudent' do
  id = params[:id].to_i
  squad = @conn.exec("SELECT * FROM squads WHERE id = $1", [id])
  @id = id
  @squad = squad[0]
  erb :newstudent
end

#EDITSTUDENT
# /squads/:squad_id/students/:student_id/edit - this route takes the user to a page that shows them a form to edit a student's information
get '/squads/:id/students/:student_id/edit' do
  squad_id = params[:id].to_i
  student_id = params[:student_id].to_i
  student = @conn.exec("SELECT * FROM squads JOIN students ON squads.id = students.squadid where squads.id = $1 AND students.id = $2", [squad_id, student_id])
  @squad_id = squad_id
  @student_id = student_id
  @student = student[0]
  erb :editstudent
end


# Your app should have the following POST routes.

#NEWSQUAD
# /squads - this route creates a new squad
post '/squads' do
  @conn.exec("INSERT INTO squads (name, mascot) VALUES ($1, $2)", [params[:name], params[:mascot]])
  redirect '/squads'
end

#NEWSTUDENT
# /squads/:squad_id/students - this route creates a new student in an existing squad
post '/squads/:squad_id/students' do
  squad_id = params[:squad_id].to_i
  name = params[:newname]
  age = params[:newage].to_i
  spiritanimal = params[:newspiritanimal]
  @conn.exec("INSERT INTO students (squadid, name, age, spiritanimal) VALUES ($1, $2, $3, $4)",[squad_id, name, age, spiritanimal])
  redirect "/squads"
end


# Your app should have the following PUT routes.

#UPDATESQUAD
# /squads/:squad_id - this route should be used for editing an existing squad
put '/squads/:squad_id' do
  # not getting the ID from the calling page params[:squad_id] is always 0
  id = params[:squad_id].to_i
  @conn.exec("UPDATE squads SET name = $1, mascot = $2 WHERE id = $3", [params[:name], params[:mascot], id])
  redirect '/squads'
end

# /squads/:squad_id/students - this route should be used for editing an existing student in a squad
put '/squads/:squad_id/students' do
  id = params[:squad_id].to_i
  name = params[:name]
  age = params[:age].to_i
  spiritanimal = params[:spiritanimal]
  @conn.exec("UPDATE students SET name = $1, age = $2, spiritanimal = $3 WHERE id = $4", [params[:name], params[:age], params[:spiritanimal], id])

  #binding.pry

  redirect '/squads'
end


# Your app should have the following DELETE routes.

# /squads/:squad_id - this route should be used for deleting an existing squad
delete '/squads/:squad_id' do
  squad_id = params[:squad_id].to_i
  @conn.exec("DELETE FROM squads WHERE id = $1", [squad_id])
  redirect '/squads'
end

# /squads/:squad_id/students/:student_id - this route should be used for editing an existing student in a squad
delete '/squads/:squad_id/students/:student_id' do
  squad_id = params[:squad_id].to_i
  student_id = params[:student_id].to_i
  @conn.exec("DELETE FROM students WHERE id = $1 AND squadid = $2", [student_id, squad_id])
  redirect '/squads'
end
