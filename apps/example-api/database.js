var pg = require('pg');

var client = new pg.Client({
    user: process.env.DB_USERNAME, // repalce with your username
    password: process.env.DB_PASSWORD, // repalce with your password if u have one
    host: process.env.DB_HOST,// repalce with your host 
    port: 5432,
    database: "datadog"
});
client.connect();
client.query('CREATE TABLE todo(id SERIAL PRIMARY KEY, nametodo VARCHAR(40) not null, iscomplete BOOLEAN)', (err, res) => {
    if (err) {
        client.end()
    } else {
        client.end()
    }
})