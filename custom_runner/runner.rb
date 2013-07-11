#!/usr/bin/env ruby
# encoding: utf-8

$i = 0
$num = 24

while $i < $num  do
   puts("")
   $i +=1
end

puts "A long time ago in a galaxy far,far away.... "
sleep 2
puts ""
crawl_array = [ 
       "",
       "     _______.___________.    ___      .______      ",
       "    /       |           |   /   \\     |   _  \\     ",
       "   |   (----`---|  |----`  /  ^  \\    |  |_)  |    ",
       "    \\   \\       |  |      /  /_\\  \\   |      /     ",
       ".----)   |      |  |     /  _____  \\  |  |\\  \\----.",
       "|_______/       |__|    /__/     \\__\\ | _| `._____|",
       "                                                   ",
       "____    __    ____  ___      .______          _______.",
       "\\   \\  /  \\  /   / /   \\     |   _  \\        /       |",
       " \\   \\/    \\/   / /  ^  \\    |  |_)  |      |   (----`",
       "  \\            / /  /_\\  \\   |      /        \\   \\    ",
       "   \\    /\\    / /  _____  \\  |  |\\  \\----.----)   |   ",
       "    \\__/  \\__/ /__/     \\__\\ | _| `._____|_______/    ",
       "",
       "","Episode IV",
      "",
      "It is a period of civil war.",
      "",
      "Rebel spaceships, striking from a",
      "",
      "hidden base, have won their",
      "",
      "first victory against the evil",
      "",
      "Galactic Empire. During the battle,",
      "",
      "Rebel spies managed to steal",
      "",
      "secret plans to the Empire's ultimate",
      "",
      "weapon, the Death Star, an armoured",
      "",
      "space station with enough power to",
      "",
      "destroy an entire planet. Pursued by the",
      "",
      "Empire's sinister agents, Princess",
      "",
      "Leia races home aboard her starship,",
      "",
      "custodian of the stolen plans that can save",
      "",
      "her people and restore freedom to the galaxy"
]

crawl_array.each do |a|
  puts a
  sleep 0.5
end

sleep 3

system "shutdown -h now"