// JQuery for Account Page
$().ready(function() {
  try {
    var canvas = $("#accountCanvas");
    var context = canvas.get(0).getContext("2d");
    var form = $(".user-form");
    var accountPic = $(".fileinput-preview");
    var oldPic = $(".thumbnail");

    $("#accountFileInput").on("change", function() {
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
                aspectRatio: 1,
                autoCropArea: 0.6,
                restore: true,
                guides: true,
                center: true,
                highlight: true,
                cropBoxMovable: true,
                cropBoxResizable: false,
                toggleDragModeOnDblclick: false,
                movable: false,
                zoomable: false,
                rotatable: false,
                scalable: false
              });
            };
            img.src = evt.target.result;
          };
          reader.readAsDataURL(this.files[0]);
        }
      }
    });
  } catch (error) {}

  $("#accountConfirm")
    .unbind("click")
    .click(function() {
      var croppedUrl = canvas
        .cropper("getCroppedCanvas")
        .toDataURL("image/png");
      if (croppedUrl != null) {
        form.append(
          $(
            `<input type="hidden" name="account_cropped_photo" value=${croppedUrl} />`
          )
        );

        accountPic.empty();
        accountPic.append($("<img>").attr("src", croppedUrl));
        oldPic.hide();
        accountPic.show();
      }
    });

  $("#passwordConfirm")
    .unbind("click")
    .click(function() {
      var oldPassword = $("#oldPass").val();
      var newPassword = $("#newPass").val();
      var confirmPassword = $("#confirmPass").val();
      var email = $("#email").val();
      console.log("Email is: " + email);
      if(newPassword.length > 5 && newPassword === confirmPassword){
        $.ajax({
          url: "/ajax/change_password",
          type: "POST",
          data: JSON.stringify({
            old_password: oldPassword,
            new_password: newPassword,
            confirm_password: confirmPassword,
            email: email
          }),
          dataType: "json",
          contentType: "application/json"
        });
      }
    });
});
