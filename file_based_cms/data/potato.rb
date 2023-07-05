require 'bcrypt'
require 'yaml'

users = {}

users["admin"] = BCrypt::Password.create("secret")
users["bob"] =  BCrypt::Password.create("bobina")
users["lapis"] = BCrypt::Password.create("lark")

File.write("users.yml", YAML.dump(users))