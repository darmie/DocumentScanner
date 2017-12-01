const express = require('express');
const path = require('path');
const favicon = require('serve-favicon');
const logger = require('morgan');
const cookieParser = require('cookie-parser');
const bodyParser = require('body-parser');

const index = require('./routes/index');

const app = express();

const server = require('http').Server(app);
const io = require('socket.io')(server);
const uuidv4 = require('uuid/v4');

//const cv = require("opencv");
const spawn = require('child_process').spawn;

const fs = require('fs');
const jpeg = require('jpeg-js');

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');

// uncomment after placing your favicon in /public
//app.use(favicon(path.join(__dirname, 'public', 'favicon.ico')));
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

//app.use('/', index);
server.listen(80);
io.on('connection', function (socket) {

  let session_key = uuidv4();
  socket.emit('connected', { session_key: session_key });

  socket.join(session_key);

  io.in(session_key).on('scan', (imgData) => {

    let imgPath = 'public'+'/images/'+session_key+'.jpg'

    saveImage(imgPath, imgData, ()=>{
     
      let py = spawn('python', ['python/scan.py', '-i', imgPath])
    
      py.stdout.on('data', (data)=> {
          console.log(data.toString())
      });
    
      py.stdout.on('end', ()=> {
        let image = fs.readFileSync(imgPath)
        let imageData = jpeg.decode(image, true);
        io.in(session_key).emit('scanned', imageData)
        //remove image file
        fs.unlinkSync(imgPath);
      });

    }, err =>{
      io.in(session_key).emit("error")
    })
  })
});

let saveImage = (path, data, cb, error) =>{
  var myBuffer = new Buffer(data);
  fs.writeFile(path, myBuffer, function(err) {
      if(err) {
          error(err);
      } else {
          cb();
      }
  });
}



// catch 404 and forward to error handler
app.use(function (req, res, next) {
  let err = new Error('Not Found');
  err.status = 404;
  next(err);
});

// error handler
app.use(function (err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});

module.exports = app;
