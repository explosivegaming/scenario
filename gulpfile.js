var gulp       = require('gulp');
var rename     = require('gulp-rename');
var luaminify  = require('gulp-luaminify');
 
gulp.task('minify', function () {
    return gulp.src(['source.lua'])
      .pipe(luaminify())
      .pipe(rename('control.lua'))
      .pipe(gulp.dest('.'));
});

gulp.task('watch', function() {
  gulp.watch('source.lua', ['minify']);
});

gulp.task('default', ['minify']);