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
      title: "Carousel Banner",
      content: "Find a good jquery carousel plugin",
      color: "yellow"
    },
    {
      title: "LiveChat Configuration Documentation",
      content: "Document live chat configuration settings",
      color: "orange"
    },
    {
      title: "Dropdown Menus",
      content: "Implement dropdown menus on forms",
      color: "red"
    },
    {
      title: "Advertising Side-banners AJAX",
      content: "load advertising content via ajax",
      color: "yellow"
    }
  ])