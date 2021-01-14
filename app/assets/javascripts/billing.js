$().ready(function() {
  var planId;
  var businessId;

  try {
    $(".update-button")
      .unbind("click")
      .click(function() {
        var value = $("input[name=plan-level]:checked").val();
        if (value == null) {
          $("#NoPlanModal").modal("show");
        } else {
          $("#PaymentModal").modal({ backdrop: "static", keyboard: false });
          planId = value;
          businessId = $(".userinfo").val();
        }
      });

    ("use strict");

    // Stripe Setup
    // var stripe = Stripe("pk_test_1ZdZebuJrRLnlxtRDS8BAulr");
    var stripe = Stripe("pk_test_YTr3JpmNMBdGwyF8xCfKQ9Qu"); // this is mine
    var elements = stripe.elements({
      fonts: [
        {
          cssSrc: "https://fonts.googleapis.com/css?family=Roboto"
        }
      ],
      locale: window.__exampleLocale
    });

    var card = elements.create("card", {
      iconStyle: "solid",
      style: {
        base: {
          color: "#212121",
          fontWeight: 500,
          fontFamily: "Source Code Pro, Consolas, Menlo, monospace",
          fontSize: "16px",
          fontSmoothing: "antialiased",

          "::placeholder": {
            color: "#2962ff"
          },
          ":-webkit-autofill": {
            color: "#e39f48"
          }
        },
        invalid: {
          color: "#E25950",

          "::placeholder": {
            color: "#FFCCA5"
          }
        }
      }
    });
    card.mount("#card-element");

    card.addEventListener("change", function(event) {
      var displayError = document.getElementById("card-errors");
      if (event.error) {
        displayError.textContent = event.error.message;
      } else {
        displayError.textContent = "";
      }
    });

    $(".purchase-button")
      .unbind("click")
      .click(function() {
        $(".stripe_payment_section").hide();
        $(".sub-modal-footer").hide();
        $(".load-container").show();

        stripe.createToken(card).then(function(result) {
          var $form = $("#payment_form");
          if (result.error) {
            var errorElement = document.getElementById("card-errors");
            errorElement.textContent = result.error.message;
            $(".stripe_payment_section").show();
            $(".load-container").hide();
            $(".sub-modal-footer").show();
          } else {
            var token = result.token.id;

            console.log("Got Token ID: " + token);

            $.ajax({
              url: "/ajax/subscribe",
              type: "POST",
              data: JSON.stringify({
                token: result.token.id,
                planId: planId,
                businessId: businessId
              }),
              dataType: "script",
              contentType: "application/json",
              success: function(result) {
                console.log("SUCCESS!!!!");
              }
            });
          }
        });
      });

    $(".cancel-sub-button")
      .unbind("click")
      .click(function() {
        businessId = $(".userinfo").val();
        $.ajax({
          url: "/ajax/cancel_subscription",
          type: "POST",
          data: JSON.stringify({
            businessId: businessId
          }),
          dataType: "script",
          contentType: "application/json",
          success: function(result) {
            console.log("SUCCESS!!!!");
          }
        });
      });

    $(".activate-sub-button")
    .unbind("click")
    .click(function() {
      businessId = $(".userinfo").val();
      $.ajax({
        url: "/ajax/activate_subscription",
        type: "POST",
        data: JSON.stringify({
          businessId: businessId
        }),
        dataType: "script",
        contentType: "application/json",
        success: function(result) {
          console.log("SUCCESS!!!!");
        }
      });
    });

    $(".update-card-button")
      .unbind("click")
      .click(function() {
        stripe.createToken(card).then(function(result) {
          var $form = $("#payment_form");
          if (result.error) {
            var errorElement = document.getElementById("card-errors");
            errorElement.textContent = result.error.message;
            $(".stripe_payment_section").show();
            $(".load-container").hide();
            $(".sub-modal-footer").show();
          } else {
            var token = result.token.id;
            businessId = $(".userinfo").val();

            $.ajax({
              url: "/ajax/update_card",
              type: "POST",
              data: JSON.stringify({
                token: result.token.id,
                businessId: businessId
              }),
              dataType: "script",
              contentType: "application/json",
              success: function(result) {
                console.log("SUCCESS!!!!");
              }
            });
          }
        });
      });

    $(".upgrade-plan-button")
      .unbind("click")
      .click(function() {
        var plan = $("input[name=plan-level]:checked").val();
        if (plan != null && plan != "") {
          businessId = $(".userinfo").val();
          $.ajax({
            url: "/ajax/update_subscription",
            type: "POST",
            data: JSON.stringify({
              planId: plan,
              businessId: businessId
            }),
            dataType: "script",
            contentType: "application/json",
            success: function(result) {
              console.log("SUCCESS!!!!");
            }
          });
        }
      });

    // Increase Counter
    $(".count").prop("disabled", true);
    var currentUserCount = parseInt( $(".count").val() );
    var limitUserCount = 7;
    var plus = $(".plus");
    var minus = $(".minus");
    var addedCost = $(".added-cost");
    var totalCost = $(".total-cost");
    var currentCost = parseInt($(".current-cost").val());

    plus.unbind("click").click(function() {
      $(".count").val(parseInt($(".count").val()) + 1);
      var additionalCost = 7 * (parseInt($(".count").val()) - currentUserCount);
      var total = currentCost + additionalCost;
      if (additionalCost < 0) {
        addedCost.text("($" + additionalCost * -1 + ")");
      } else {
        addedCost.text("$" + additionalCost);
      }
      
      totalCost.text("$" + total);
    });

    minus.unbind("click").click(function() {
      if (parseInt( $(".count").val() ) !== limitUserCount) {
        $(".count").val(parseInt($(".count").val()) - 1);
        var additionalCost = 7 * (parseInt($(".count").val()) - currentUserCount);
        var total = currentCost + additionalCost;
        if (additionalCost < 0) {
          addedCost.text("($" + additionalCost * -1 + ")");
        } else {
          addedCost.text("$" + additionalCost);
        }
        
        totalCost.text("$" + total);
      }

      
    });

    $(".add-users-button")
      .unbind("click")
      .click(function() {
        $(".add-user-area").hide();
        $(".add-user-footer").hide();
        $(".add-user-loader").show();

        var userAmount = parseInt($(".count").val());
        if (userAmount !== currentUserCount) {
          
          console.log("Add " + userAmount + " To Subscription");
          businessId = $(".userinfo").val();

          $.ajax({
            url: "/ajax/update_users_subscription",
            type: "POST",
            data: JSON.stringify({
              businessId: businessId,
              userAmount: userAmount
            }),
            dataType: "script",
            contentType: "application/json",
            success: function(result) {
              console.log("SUCCESS!!!!");
            }
          });
        }
        
      });
  } catch (e) {
    // Ignore
  }
});
