// $().ready(function() {
//   var modal = false;
//   if (modal) {
//     $("#StripeModal").modal("show");
//   }
//
//   //$('#StripeButton').prop('disabled', true);
//
//   ("use strict");
//
//   // Stripe Setup
//   var stripe = Stripe("pk_test_CzocQRHhnTUXeOIS7Bj3AWq6");
//   var elements = stripe.elements({
//     fonts: [
//       {
//         cssSrc: "https://fonts.googleapis.com/css?family=Roboto"
//       }
//     ],
//     locale: window.__exampleLocale
//   });
//
//   var card = elements.create("card", {
//     iconStyle: "solid",
//     style: {
//       base: {
//         color: "#212121",
//         fontWeight: 500,
//         fontFamily: "Source Code Pro, Consolas, Menlo, monospace",
//         fontSize: "16px",
//         fontSmoothing: "antialiased",
//
//         "::placeholder": {
//           color: "#2962ff"
//         },
//         ":-webkit-autofill": {
//           color: "#e39f48"
//         }
//       },
//       invalid: {
//         color: "#E25950",
//
//         "::placeholder": {
//           color: "#FFCCA5"
//         }
//       }
//     }
//   });
//   card.mount("#card-element");
//
//   card.addEventListener("change", function(event) {
//     var displayError = document.getElementById("card-errors");
//     if (event.error) {
//       displayError.textContent = event.error.message;
//     } else {
//       displayError.textContent = "";
//     }
//   });
//
//   form.submit(function(event) {
//     event.preventDefault();
//     $('input[type="tel"]').each(function() {
//       if ($(this).val() != "") {
//         var formatted = $(this).intlTelInput("getNumber");
//         $(this).val(formatted);
//       }
//     });
//     var $form = $(this);
//     stripe.createToken(card).then(function(result) {
//       stripeResponseHandler(result);
//     });
//     return false;
//   });
//
//   function stripeResponseHandler(result) {
//     var $form, token;
//     $form = $("#payment_form");
//     if (result.error) {
//       var errorElement = document.getElementById("card-errors");
//       errorElement.textContent = result.error.message;
//     } else {
//       token = result.token.id;
//       $form.append(
//         $(`<input type="hidden" name="stripeToken" value=${token} />`)
//       );
//       $form.get(0).submit();
//     }
//   }
// });
