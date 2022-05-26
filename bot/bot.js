//env values
require('dotenv').config();

//set up express server
const express = require('express');
const app = express();
const PORT = process.env.PORT || 1337

//set up discord bot
const { Client, Intents } = require('discord.js');
const bot = new Client({ intents: [Intents.FLAGS.GUILDS, Intents.FLAGS.GUILD_MESSAGES] });

//run express server
function runServer() { app.listen(PORT, () => {
    console.log(`App is listening at http://localhost:${PORT}`)
});
}
runServer()
bot.on('ready', () => {
	console.log(`${bot.user.tag} started and runs`)
})

//data containers
let usersActivity = {} //object with data of users, stores user id and timestamps of 5 last messages
let registeredUsers = []; //array of the registered users


//handler fo messages
bot.on('message', (msg) => {

	if (!msg.author.bot) { //checks if msg is not from the bot

		let timestamp = "" //variable for timestamp + convert to string

		timestamp += msg.createdTimestamp; 

		if (!registeredUsers.includes(msg.author.id)) { //check if user is already registered
			registerNewUser(msg.author.id, timestamp); //add new user
		} else {
			if (usersActivity[msg.author.id].length < 5) { //check number of timestamps of the user
				addNewTimestamp(msg.author.id, timestamp) 
			} else { //if user already has 5 timestamps, removes the oldest one and adds new
				usersActivity[msg.author.id].pop()
				addNewTimestamp(msg.author.id, timestamp)
			}
			
		}
	}

})

function registerNewUser(id, firstMessage) { //add a new user to list of registered and to data object
	registeredUsers.push(id + "");
	usersActivity[id] = [firstMessage];
}

function addNewTimestamp(id, timestamp) { // adds new timestamp in the beginning of timestamps array
	usersActivity[id].unshift(timestamp)
}

app.get('/all-users', (req, res) => res.send(usersActivity)); //route for object with all users data

app.get('/registered-users', (req, res) => res.send(registeredUsers)); //route for array with registered users

app.get('/user-data/:userId', (req, res) => {
	const userId = req.params.userId;
	console.log(req.params.userId);
	if(usersActivity[userId] != null) {
		res.send(usersActivity[userId]); //route for object with all users data
	} else {
		res.send({});
	}
});

bot.login(process.env.TOKEN);