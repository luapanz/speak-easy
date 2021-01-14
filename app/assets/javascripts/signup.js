// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$().ready(function() {
  var form;
  var regex = /^(.*)(\d)+$/i;
  var $signup = $(".signup");
  var $profile = $(".profile");

  form = $(".user-form");

  $(".signup_phone").on('input', function(){
    var value = $(".signup_phone").val();
    $(".signup_phone").val(value.replace(/[^\d.]/g, ''));
  });

  form.formValidation({
    framework: "bootstrap",
    fields: {
      "user[email]": {
        trigger: "blur",
        message: "The email is not valid",
        validators: {
          notEmpty: {
            message: "The email is required"
          },
          remote: {
            enabled: $signup.length > 0,
            message: "This email is already registered",
            url: "/ajax/check_email",
            type: "POST"
          }
        }
      },
      "user[tos_version]": {
        validators: {
          notEmpty: {
            message: "You must agree with the terms and conditions"
          }
        }
      },
      "user[password_confirmation]": {
        validators: {
          identical: {
            field: "user[password]",
            message: "The password and its confirm are not the same"
          }
        }
      }
    }
  });

  var fv = form.data("formValidation");

  $("#tos_decline").click(function(e) {
    $("#tos_accept_check").prop("checked", false);
    $("form").formValidation("revalidateField", "user[tos_version]");
  });

  $("#tos_accept").click(function(e) {
    $("#tos_accept_check").prop("checked", true);
    $("form").formValidation("revalidateField", "user[tos_version]");
  });

  $('#hide-password').click(function(e){
    console.log($('.password').val());
    if($('#hide-password').prop('checked')){
      console.log("YES");
      $('.password').get(0).setAttribute('type', 'password');
    }
    else{
      console.log("NO");
      $('.password').get(0).setAttribute('type', 'text');
    }
  });

  $("#user_email").blur(function() {
    var self = $(this);
    self.val(self.val().trim());
  });

  var $email = $("#user_email");
  var email = $email.val();

  $email.blur(function() {
    if ($(this).val() === email) {
      return false;
    } else {
      fv.enableFieldValidators("user[email]", true, "remote")
        .revalidateField("user[email]")
        .enableFieldValidators("user[email]", false, "remote");
    }
  });
});
