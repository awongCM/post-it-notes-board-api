# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

notes = Note.create(
  [
    {
      title: "Post It Notes Buttons ",
      content: "Add 3 post it notes buttons ie feature, nice to have and urgent notes",
      color: "orange"
    },
    {
      title: "Style Post It Notes Button",
      content: "Style post it notes buttons' background color",
      color: "yellow"
    },
    {
      title: "Post It Notes Back-end RESTFUL API",
      content: "Implement RESTFUL API using RAILS",
      color: "red"
    },
    {
      title: "Draggable Post It Notes",
      content: "Make all new and existing post it notes draggable on the board",
      color: "orange"
    },
    {
      title: "Style Post It Notes Board",
      content: "Decorate the board using brick-wall-layout CSS",
      color: "yellow"
    }
  ])