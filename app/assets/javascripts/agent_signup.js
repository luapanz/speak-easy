$().ready(function() {
  $(".signup-text")
    .unbind("click")
    .click(function() {
      var phoneNumber = $("#signupNumber").val();
      var locationId = $("#location").val();
      var businessId = $("#business").val();

      if (
        phoneNumber.length === 10 &&
        locationId.length === 10 &&
        businessId.length === 10
      ) {
        $.ajax({
          url: "/ajax/send_team_sms",
          type: "POST",
          data: JSON.stringify({
            phoneNumber: phoneNumber,
            businessId: businessId,
            locationId: locationId
          }),
          dataType: "json",
          contentType: "application/json"
        });
      }
    });
});
