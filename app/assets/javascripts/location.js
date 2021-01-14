$().ready(function() {
  var $form = $(".locations-form");
  var $physical = $(".location-edit-physical");

  if ($form.length > 0) {
    $form.formValidation({
      framework: "bootstrap",
      fields: {
        "location[country]": {
          validators: {
            notEmpty: {
              message: "Please select country"
            }
          }
        },
      }
    });

    function filter_location_form($field) {
      $physical.toggle();
    }

    $("#user_locations__is_virtual").on("change", function(event) {
      event.stopImmediatePropagation();
      filter_location_form(this);
    });

  }

  try{
    var canvas = $("#editCanvas");
    var context = canvas.get(0).getContext("2d");
    var editPic = $("#editPic");

    $("#editFileInput").on("change", function() {
      if (this.files && this.files[0]) {
        if (this.files[0].type.match(/^image\//)) {
          var reader = new FileReader();
          reader.onload = function(evt) {
            var img = new Image();
            img.onload = function() {
              context.canvas.width = img.width;
              context.canvas.height = img.height;
              context.drawImage(img, 0, 0);
              canvas.cropper("destroy");
              var cropper = canvas.cropper({
                aspectRatio: 16 / 9,
                autoCropArea: 0.9,
                restore: true,
                guides: true,
                center: true,
                highlight: true,
                cropBoxMovable: true,
                cropBoxResizable: false,
                toggleDragModeOnDblclick: false,
                movable: false,
                zoomable: true,
                rotatable: false,
                scalable: true
              });
            };
            img.src = evt.target.result;
          };
          reader.readAsDataURL(this.files[0]);
        }
      }
    });
  }
  catch(error){
  }

  $("#editConfirm").click(function() {
    var croppedUrl = canvas.cropper('getCroppedCanvas').toDataURL("image/png");
    if(croppedUrl != null){
      $form.append($(`<input type="hidden" name="edit_cropped_photo" value=${croppedUrl} />`));
      editPic.empty();
      editPic.append($('<img>').attr('src', croppedUrl));
    }
  });
});
