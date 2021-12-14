#1 "server/template.eml.html"
let render param =
let ___eml_buffer = Buffer.create 4096 in
(Buffer.add_string ___eml_buffer "<html>\n  <head>\n    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n    <style>\n    .top-of-page{\n      font-family: Arial, Helvetica, sans-serif;\n      font-size: 50px;\n      background-color: skyblue;\n      width: max-content;\n      height: min-content;\n      margin-left: auto;\n      margin-right: auto;\n      border-radius: 5px;\n    }\n    .background{\n      background-color: lightslategray;\n      justify-content: center;\n      align-content: center;\n    }\n    .solve-selector{\n      display: grid;\n      grid-template-columns: auto auto auto;\n      padding: 20px;\n      justify-content: space-evenly;\n    }\n    .choice{\n      width: 100px;\n      height: 50px;\n      background-color: skyblue;\n      border-radius: 25px;\n      text-align: center;\n      vertical-align: center;\n      margin: auto;\n      padding: 10px;\n      font-weight: bold;\n      font-family: Arial, Helvetica, sans-serif;\n      cursor: pointer;\n    }\n    .choice:hover {\n    background-color: #008CBA;\n    color: white;\n    }\n    .color-selector{\n      display: grid;\n      grid-template-columns: auto auto auto auto auto auto;\n      background-color: skyblue;;\n      justify-content: space-evenly;\n      border-radius: 25px;\n      height: 100px;\n      align-content: center;\n    }\n    .selector{\n      width: 70px;\n      height: 70px;\n      cursor: pointer;\n    }\n    .red-selector{\n      background-color: red;\n    }\n    .blue-selector{\n      background-color: blue;\n    }\n    .yellow-selector{\n      background-color: yellow;\n    }\n    .green-selector{\n      background-color: green;\n    }\n    .white-selector{\n      background-color: white;\n    }\n    .orange-selector{\n      background-color: orange;\n    }\n    .outer-grid {\n      display: grid;\n      grid-template-columns: 270px 270px 270px 270px;\n      padding: 50px;\n    }\n    .grid-container {\n      display: grid;\n      grid-template-columns: 90px 90px 90px;\n    }\n    .grid-item {\n      background-color: rgba(255, 255, 255, 0.8);\n      border: 1px solid rgba(0, 0, 0, 0.8);\n      padding: 20px;\n      font-size: 30px;\n      text-align: center;\n      height: 50px;\n      width: 50px;\n    }\n    .grid-item:hover{\n      background-color: azure;\n    }\n    p {\n      text-align: center;\n      text-justify: center;\n      text-emphasis: bold;\n      text-transform: uppercase;\n      background-color: white;\n      max-width: 40ch;\n      margin: 20px auto;\n      font-size: 20pt;\n      font-family: Arial, Helvetica, sans-serif;\n      border-radius: 10px;\n      \n    }\n\n    </style>\n    </head>\n\n<body class=\"background\">\n  <h1 class=\"top-of-page\">The Rubik's Wrecker</h1>\n  <div class= \"solve-selector\">\n    <button onClick=\"window.location.reload()\" class=\"choice\">Reset</button>\n    <button onClick=\"revealSolved();\" class=\"choice\">Solved Cube</button>\n    <button id=\"Solve\" onClick=\"displaySolution();\" class=\"choice\">Solve</button>\n    <script>\n      function displaySolution() {\n        var facelets = document.getElementsByClassName('grid-item');\n        var color_array = [];\n        var array_of_facelets = Array.from(facelets);\n        var arr_position = 0; \n        for (let i of array_of_facelets) {\n          color_array[arr_position] = i.style.backgroundColor;\n          arr_position++;\n        }\n        socket.send(color_array);\n      }\n\n      var socket = new WebSocket(\"ws://\" + window.location.host + \"/websocket\"); \n\n      socket.onmessage = function (e) {\n        console.log(\"Here\")\n        document.getElementById('solution').textContent = \"Moves: \" + e.data;\n      };\n\n      function revealSolved() {\n        var blue_names = document.getElementsByName(\"blue\"); \n        var green_names = document.getElementsByName(\"green\"); \n        var yellow_names = document.getElementsByName(\"yellow\"); \n        var orange_names = document.getElementsByName(\"orange\"); \n        var red_names = document.getElementsByName(\"red\"); \n        var white_names = document.getElementsByName(\"white\"); \n        blue_names.forEach((blue) => blue.style.backgroundColor = 'blue')\n        green_names.forEach((green) => green.style.backgroundColor = 'green')\n        yellow_names.forEach((yellow) => yellow.style.backgroundColor = 'yellow')\n        orange_names.forEach((orange) => orange.style.backgroundColor = 'orange')\n        red_names.forEach((red) => red.style.backgroundColor = 'red')\n        white_names.forEach((white) => white.style.backgroundColor = 'white')\n      }\n    </script>\n  </div>\n  <p class=\"solution-text\" id=\"solution\" style=\"text-emphasis: bold;\"></p>\n  <div id=\"color_select\" class =\"color-selector\">\n    <button onclick=\"myFunction('red')\" class=\"selector red-selector\"> </button>\n    <button onclick=\"myFunction('blue')\" class=\"selector blue-selector\"></button>\n    <button onclick=\"myFunction('yellow')\" class=\"selector yellow-selector\"></button>\n    <button onclick=\"myFunction('green')\" class=\"selector green-selector\"></button>\n    <button onclick=\"myFunction('white')\" class=\"selector white-selector\"></button>\n    <button onclick=\"myFunction('orange')\" class=\"selector orange-selector\"></button>\n    <script>\n      function myFunction(clr) {\n        document.getElementById(\"color_select\").style.backgroundColor = clr;\n      }\n    </script>\n  </div>\n  <div class= \"outer-grid\">\n    <div class=\"grid-container\">\n    </div>\n    <div class=\"grid-container\">\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#174 "server/template.eml.html"
                      String.sub param 0 6
)));
(Buffer.add_string ___eml_buffer " id=\"U1\" onclick=\"colorChange('U1')\" class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#175 "server/template.eml.html"
                      String.sub param 6 6
)));
(Buffer.add_string ___eml_buffer " id=\"U2\" onclick=\"colorChange('U2')\" class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#176 "server/template.eml.html"
                      String.sub param 12 6
)));
(Buffer.add_string ___eml_buffer " id=\"U3\" onclick=\"colorChange('U3')\" class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#177 "server/template.eml.html"
                      String.sub param 18 6
)));
(Buffer.add_string ___eml_buffer " id=\"U4\" onclick=\"colorChange('U4')\" class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#178 "server/template.eml.html"
                      String.sub param 24 6
)));
(Buffer.add_string ___eml_buffer " class=\"grid-item\" style=\"background-color: white\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#179 "server/template.eml.html"
                      String.sub param 30 6
)));
(Buffer.add_string ___eml_buffer " id=\"U6\" onclick=\"colorChange('U6')\" class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#180 "server/template.eml.html"
                      String.sub param 36 6
)));
(Buffer.add_string ___eml_buffer " id=\"U7\" onclick=\"colorChange('U7')\" class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#181 "server/template.eml.html"
                      String.sub param 42 6
)));
(Buffer.add_string ___eml_buffer " id=\"U8\" onclick=\"colorChange('U8')\" class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#182 "server/template.eml.html"
                      String.sub param 48 6
)));
(Buffer.add_string ___eml_buffer " id=\"U9\" onclick=\"colorChange('U9')\"class=\"grid-item\"></div>\n    </div> \n    <div class=\"grid-container\">\n    </div>\n    <div class=\"grid-container\">\n    </div>\n    <div class=\"grid-container\">\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#189 "server/template.eml.html"
                      String.sub param 54 6
)));
(Buffer.add_string ___eml_buffer " id=\"L1\" onclick=\"colorChange('L1')\" class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#190 "server/template.eml.html"
                      String.sub param 60 6
)));
(Buffer.add_string ___eml_buffer " id=\"L2\" onclick=\"colorChange('L2')\" class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#191 "server/template.eml.html"
                      String.sub param 66 6
)));
(Buffer.add_string ___eml_buffer " id=\"L3\" onclick=\"colorChange('L3')\" class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#192 "server/template.eml.html"
                      String.sub param 72 6
)));
(Buffer.add_string ___eml_buffer " id=\"L4\" onclick=\"colorChange('L4')\" class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#193 "server/template.eml.html"
                      String.sub param 78 6
)));
(Buffer.add_string ___eml_buffer " class=\"grid-item\" style=\"background-color: green\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#194 "server/template.eml.html"
                      String.sub param 84 6
)));
(Buffer.add_string ___eml_buffer " id=\"L6\" onclick=\"colorChange('L6')\" class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#195 "server/template.eml.html"
                      String.sub param 90 6
)));
(Buffer.add_string ___eml_buffer " id=\"L7\" onclick=\"colorChange('L7')\" class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#196 "server/template.eml.html"
                      String.sub param 96 6
)));
(Buffer.add_string ___eml_buffer " id=\"L8\" onclick=\"colorChange('L8')\" class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#197 "server/template.eml.html"
                      String.sub param 102 6
)));
(Buffer.add_string ___eml_buffer " id=\"L9\" onclick=\"colorChange('L9')\" class=\"grid-item\"></div>\n    </div>\n    <div class=\"grid-container\">\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#200 "server/template.eml.html"
                      String.sub param 108 6
)));
(Buffer.add_string ___eml_buffer " id=\"F1\" onclick=\"colorChange('F1')\" class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#201 "server/template.eml.html"
                      String.sub param 114 6
)));
(Buffer.add_string ___eml_buffer " id=\"F2\" onclick=\"colorChange('F2')\" class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#202 "server/template.eml.html"
                      String.sub param 120 6
)));
(Buffer.add_string ___eml_buffer " id=\"F3\" onclick=\"colorChange('F3')\" class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#203 "server/template.eml.html"
                      String.sub param 126 6
)));
(Buffer.add_string ___eml_buffer " id=\"F4\" onclick=\"colorChange('F4')\"class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#204 "server/template.eml.html"
                      String.sub param 132 6
)));
(Buffer.add_string ___eml_buffer " class=\"grid-item\" style=\"background-color: red\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#205 "server/template.eml.html"
                      String.sub param 138 6
)));
(Buffer.add_string ___eml_buffer " id=\"F6\" onclick=\"colorChange('F6')\" class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#206 "server/template.eml.html"
                      String.sub param 144 6
)));
(Buffer.add_string ___eml_buffer " id=\"F7\" onclick=\"colorChange('F7')\" class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#207 "server/template.eml.html"
                      String.sub param 150 6
)));
(Buffer.add_string ___eml_buffer " id=\"F8\" onclick=\"colorChange('F8')\" class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#208 "server/template.eml.html"
                      String.sub param 156 6
)));
(Buffer.add_string ___eml_buffer " id=\"F9\" onclick=\"colorChange('F9')\"class=\"grid-item\"></div>\n    </div>\n    <div class=\"grid-container\">\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#211 "server/template.eml.html"
                      String.sub param 162 6
)));
(Buffer.add_string ___eml_buffer " id=\"R1\" onclick=\"colorChange(this.id)\"  class=\"grid-item\" ></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#212 "server/template.eml.html"
                      String.sub param 168 6
)));
(Buffer.add_string ___eml_buffer " id=\"R2\" onclick=\"colorChange(this.id)\"  class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#213 "server/template.eml.html"
                      String.sub param 174 6
)));
(Buffer.add_string ___eml_buffer " id=\"R3\" onclick=\"colorChange(this.id)\" class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#214 "server/template.eml.html"
                      String.sub param 180 6
)));
(Buffer.add_string ___eml_buffer " id=\"R4\" onclick=\"colorChange(this.id)\" class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#215 "server/template.eml.html"
                      String.sub param 186 6
)));
(Buffer.add_string ___eml_buffer " class=\"grid-item\" style=\"background-color: blue\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#216 "server/template.eml.html"
                      String.sub param 192 6
)));
(Buffer.add_string ___eml_buffer " id=\"R6\" onclick=\"colorChange(this.id)\" class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#217 "server/template.eml.html"
                      String.sub param 198 6
)));
(Buffer.add_string ___eml_buffer " id=\"R7\" onclick=\"colorChange(this.id)\" class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#218 "server/template.eml.html"
                      String.sub param 204 6
)));
(Buffer.add_string ___eml_buffer " id=\"R8\" onclick=\"colorChange(this.id)\" class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#219 "server/template.eml.html"
                      String.sub param 210 6
)));
(Buffer.add_string ___eml_buffer " id=\"R9\" onclick=\"colorChange(this.id)\" class=\"grid-item\"></div>\n    </div>\n    <div class=\"grid-container\">\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#222 "server/template.eml.html"
                      String.sub param 216 6
)));
(Buffer.add_string ___eml_buffer " id=\"B1\" onclick=\"colorChange('B1')\" class=\"grid-item\">\n        <div class=\"popup-selector\" id=\"B1p\"><span class=\"popup\"></span></div>\n      </div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#225 "server/template.eml.html"
                      String.sub param 222 6
)));
(Buffer.add_string ___eml_buffer " id=\"B2\" onclick=\"colorChange('B2')\" class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#226 "server/template.eml.html"
                      String.sub param 228 6
)));
(Buffer.add_string ___eml_buffer " id=\"B3\" onclick=\"colorChange('B3')\" class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#227 "server/template.eml.html"
                      String.sub param 234 6
)));
(Buffer.add_string ___eml_buffer " id=\"B4\" onclick=\"colorChange('B4')\"class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#228 "server/template.eml.html"
                      String.sub param 240 6
)));
(Buffer.add_string ___eml_buffer " class=\"grid-item\" style=\"background-color: orange\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#229 "server/template.eml.html"
                      String.sub param 246 6
)));
(Buffer.add_string ___eml_buffer " id=\"B6\" onclick=\"colorChange('B6')\" class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#230 "server/template.eml.html"
                      String.sub param 252 6
)));
(Buffer.add_string ___eml_buffer " id=\"B7\" onclick=\"colorChange('B7')\" class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#231 "server/template.eml.html"
                      String.sub param 258 6
)));
(Buffer.add_string ___eml_buffer " id=\"B8\" onclick=\"colorChange('B8')\" class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#232 "server/template.eml.html"
                      String.sub param 264 6
)));
(Buffer.add_string ___eml_buffer " id=\"B9\" onclick=\"colorChange('B9')\" class=\"grid-item\"></div>\n    </div>\n    <div class=\"grid-container\">\n    </div>\n    <div class=\"grid-container\">\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#237 "server/template.eml.html"
                      String.sub param 270 6
)));
(Buffer.add_string ___eml_buffer " id=\"D1\" onclick=\"colorChange('D1')\" class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#238 "server/template.eml.html"
                      String.sub param 276 6
)));
(Buffer.add_string ___eml_buffer " id=\"D2\" onclick=\"colorChange('D2')\" class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#239 "server/template.eml.html"
                      String.sub param 282 6
)));
(Buffer.add_string ___eml_buffer " id=\"D3\" onclick=\"colorChange('D3')\" class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#240 "server/template.eml.html"
                      String.sub param 288 6
)));
(Buffer.add_string ___eml_buffer " id=\"D4\" onclick=\"colorChange('D4')\"class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#241 "server/template.eml.html"
                      String.sub param 294 6
)));
(Buffer.add_string ___eml_buffer " class=\"grid-item\" style=\"background-color: yellow\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#242 "server/template.eml.html"
                      String.sub param 300 6
)));
(Buffer.add_string ___eml_buffer " id=\"D6\" onclick=\"colorChange('D6')\" class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#243 "server/template.eml.html"
                      String.sub param 306 6
)));
(Buffer.add_string ___eml_buffer " id=\"D7\" onclick=\"colorChange('D7')\" class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#244 "server/template.eml.html"
                      String.sub param 312 6
)));
(Buffer.add_string ___eml_buffer " id=\"D8\" onclick=\"colorChange('D8')\" class=\"grid-item\"></div>\n      <div name=");
(Printf.bprintf ___eml_buffer "%s" (Dream.html_escape (
#245 "server/template.eml.html"
                      String.sub param 318 6
)));
(Buffer.add_string ___eml_buffer " id=\"D9\" onclick=\"colorChange('D9')\" class=\"grid-item\"></div>\n    </div>\n    <div class=\"grid-container\">\n    </div>\n    <div class=\"grid-container\">\n    </div>\n    <script>\n      function colorChange(id) {\n        var faceletCol = document.getElementById(id).style.backgroundColor;\n        var setColor = document.getElementById(\"color_select\").style.backgroundColor;\n        switch (setColor) {\n          case \"\": \n            switch (faceletCol) {\n              case \"\":\n                document.getElementById(id).style.backgroundColor = 'red';\n                break;\n              case 'red':\n                console.log(\"here\");\n                document.getElementById(id).style.backgroundColor = 'orange';\n                break;\n              case \"orange\":\n                document.getElementById(id).style.backgroundColor = 'blue';\n                break;\n              case \"blue\":\n                document.getElementById(id).style.backgroundColor = 'green';\n                break;\n              case \"green\":\n                document.getElementById(id).style.backgroundColor = 'yellow';\n                break;\n              case \"yellow\":\n                document.getElementById(id).style.backgroundColor = 'white';\n                break;\n              case \"white\": \n                document.getElementById(id).style.backgroundColor = \"red\";\n                break;\n            } break; \n            default: document.getElementById(id).style.backgroundColor = setColor;\n        }\n      }\n    </script>\n  </div>\n</body>\n</html>");
(Buffer.contents ___eml_buffer)
