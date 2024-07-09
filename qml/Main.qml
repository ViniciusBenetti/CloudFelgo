import Felgo 
import QtQuick 
import QtQuick.Window 
import QtQuick.Controls 
import QtPositioning 
import QtLocation
import QtMultimedia


App {


     SoundEffect{
       source: "../sounds/electric.wav"
       id: beep
          
      }




    Storage {
        id: storage

        Component.onCompleted: {
            var horariosFim = storage.getValue("horarios-fim")

            var savedData = storage.getValue("listaExModelo");
            if (savedData) {
            var savedReps = storage.getValue("listaRpModelo");
            console.log(savedReps)
            console.log('carregou')
            }
        }
    }


  
    FontLoader {
        id: roboto
        source: "../fonts/Roboto-Regular.ttf"
    }
    FontLoader {
        id: robotoBold
        source: "../fonts/Roboto-Bold.ttf"
    }

    FontLoader {
        id: brasil
        source: "../fonts/PlaywriteBR-Regular.ttf"
    }
    FontLoader {
        id: franca
        source: "../fonts/PlaywriteFRModerne-Light.ttf"
    }


  onInitTheme:{

  Theme.navigationBar.titleAlignLeft = false
  Theme.navigationBar.backgroundColor = "dark red"
  Theme.colors.backgroundColor = "black"
  Theme.navigationTabBar.backgroundColor = "dark red"
  Theme.navigationTabBar.titleOffColor = "black"
  Theme.colors.textColor = "white"
  Theme.colors.secondaryTextColor = "white"
  Theme.normalFont = franca
  Theme.boldFont = robotoBold 

  }

  onSplashScreenFinished: navegacao.currentIndex = 1


  Navigation {
    id: "navegacao"
    navigationMode: navigationModeTabs

    NavigationItem {
      title: "histórico"
      iconType: IconType.history

      NavigationStack {
        
        AppPage{
          title: "histórico"

          Component.onCompleted: {
            var horariosInicio = storage.getValue("horarios-inicio")
            var horariosFim = storage.getValue("horarios-fim")
            var datasCorrida = storage.getValue("datas-corrida")
            var distancias = storage.getValue("distancias")

            if(horariosInicio){
              var horariosParse = JSON.parse(horariosInicio)

              for(var i =0;i<horariosParse.length;i++){
                var dataValor = JSON.parse(datasCorrida)[i] || "nulo"
                var horarioInicioValor = horariosParse[i] || "nulo"
                var horarioFimValor = JSON.parse(horariosFim)[i] || "nulo"
                var distanciaValor = JSON.parse(distancias)[i] || "0"
                var inicioMinutos = parseInt(horarioInicioValor.substring(0, 2)) * 60 +
                 parseInt(horarioInicioValor.substring(3));
                 var fimMinutos = parseInt(horarioFimValor.substring(0, 2)) * 60 +
                parseInt(horarioFimValor.substring(3));

                var paceValor = Math.abs(inicioMinutos - fimMinutos) / (distanciaValor / 1000)|| 0;
                var paceAjustado = paceValor.toFixed(2);
                listModel.append({ title: dataValor,
                body:"<br/>horario de início: "+horarioInicioValor +
                     "<br/>horario de fim: "+horarioFimValor +
                     "<br/>distancia: "+distanciaValor + "m"+
                     "<br/>pace médio: "+paceAjustado+ " min/km"});
              }

            }else{
              console.log("sem historico")
            }


          }
          ListView {
        anchors.fill: parent
        model: ListModel {
            id: listModel
        }

        delegate: Item {
            width: parent.width
            height: 150

            Rectangle {
                width: parent.width
                height: 150
                color: "black"

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "data: "+model.title
                    color: "gray"
                    font: robotoBold.font
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter 
                    anchors.verticalCenterOffset: 5

                    text: model.body

                    font: robotoBold.font
                    color: "gray"
                }
                Rectangle{
                  width: parent.width 
                  height: 0.5
                  color: "dark gray" 
                  anchors.bottom: parent.bottom
                }
            }
        }
    }
        }
          }
        }
    NavigationItem {
      title: "começar"
      iconType: IconType.globe

      NavigationStack{

      AppPage{
        title: "começar"



      AppMap {
        property int distanciaTotal: 0 
        property int distanciaZerar: 0
        property double lat1: 0
        property double lon1: 0 
        property var coordinates:  []
        id: map

        AppText{
        id: distance 
        text: ""
        scale: 1.8
        color: "black"
        font: robotoBold.font
        anchors.centerIn: parent
        anchors.verticalCenterOffset: dp(40)
  


      }

        anchors.fill: parent
        enableUserPosition : true
        showUserPosition : true
        zoomLevel: 13
        Component.onCompleted: {


          if(userPositionAvailable)
          center = userPosition.coordinate
          zoomToUserPosition()
          }

          onUserPositionChanged: {


            function haversine(lat1, lon1, lat2, lon2) {
              var R = 6371; 
              var dLat = deg2rad(lat2 - lat1);
              var dLon = deg2rad(lon2 - lon1);

            var a =
             Math.sin(dLat / 2) * Math.sin(dLat / 2) +
             Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) *
             Math.sin(dLon / 2) * Math.sin(dLon / 2);

            var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
            var distance = R * c * 1000; 

            return distance;
            }

            function deg2rad(deg) {
            return deg * (Math.PI / 180);
            }
            
            if(map.lon1 != 0 && map.lat1 != 0){
            
            var long1 = map.lon1 
            var lati1 = map.lat1
            center = userPosition.coordinate
            var lat2 = userPosition.coordinate.latitude;
            var lon2 = userPosition.coordinate.longitude;
            coordinates[0] = {lat: lati1, long: lon1};
            coordinates.push({ lat: lat2, lon: lon2 });
            map.distanciaTotal = 0;
            for (var i = 1; i < coordinates.length; i++) {
            var d = haversine(coordinates[i - 1].lat, coordinates[i - 1].lon, coordinates[i].lat, coordinates[i].lon);
            map.distanciaTotal += d;
          }

        distance.text = Math.floor(map.distanciaTotal) + "m";

          }
      
  
            }
        
         plugin: Plugin {
           name: "maplibregl"
           parameters: [
         PluginParameter {
           name: "maplibregl.mapping.additional_style_urls"
           value: "https://api.maptiler.com/maps/bf31ce7b-77b2-4c32-ac31-53cf261455d4/style.json?key=h2ny0pBWyCAtuJXIGn2j"
         }
       ]
         }     
         
        }
       

      }
    Item {
      anchors.centerIn: parent
      
    Timer {
        property int repIndex
        property int tempoTotal
        property int firstIndex:0
        id: timer
        interval: 1000; running:false; repeat: true
        onTriggered:{


          var horas = time.text.substring(0,2)
          var minutos = time.text.substring(3,5)
          var segundos = time.text.substring(6,8)
          var paceStatus = 0

          var savedReps = storage.getValue("listaRpModelo")
          if(savedReps !== undefined){
            var repsParse = JSON.parse(savedReps)
            if(repIndex >= repsParse.length){
              timer.running = false
              beep.play()
              stopRep.visible = false
              var nova_data = new Date()
              var horario_formatado = nova_data.toLocaleTimeString("pt-br")
              var data_corrida = nova_data.toLocaleDateString("pt-br")
              var horariosSalvo = storage.getValue("horarios-fim")
              var datasCorrida = storage.getValue("datas-corrida")
              var distancia = storage.getValue("distancias")
              if(horariosSalvo){
                var horariosParse = JSON.parse(horariosSalvo)
                var datasParse = JSON.parse(datasCorrida)
                var distanciaParse = JSON.parse(distancia)

              }else{
                var horariosParse = [];
                var datasParse = []
                var distanciaParse = []
              }

              horariosParse.push(horario_formatado);
              datasParse.push(data_corrida);
              distanciaParse.push(map.distanciaTotal);
              storage.setValue("distancias",JSON.stringify(distanciaParse))
              storage.setValue("horarios-fim",JSON.stringify(horariosParse)); 
              storage.setValue("datas-corrida",JSON.stringify(datasParse));
      
              time.text = "00:00:00"
              distance.text = "0m"
              ativo.text = ""
              pace.text = ""
              map.lon1 = 0 
              map.lat1 = 0
              pauseRep.visible = false
              resumeRep.visible = true 
              resumeRep.anchors.horizontalCenterOffset = 0

            }

            if(time.text == "00:00:00"){
              repIndex = 0
            }
            if(!repsParse[repIndex].includes("rápido")&&!repsParse[repIndex].includes("lento")&&!repsParse[repIndex].includes("moderado")){
              ativo.text = parseInt(repsParse[repIndex]) + "m correr"

              if(firstIndex == 0){
                  map.distanciaZerar += parseInt(repsParse[repIndex])
                  firstIndex++
              }
              

              if(map.distanciaTotal  >= map.distanciaZerar){
              tempoTotal = 0
              repIndex++
              firstIndex = 0
              beep.play()
              }

            }else{
              if(repsParse[repIndex].includes("rápido")){
                  map.distanciaZerar = map.distanciaTotal
                  ativo.text = parseInt(repsParse[repIndex]) + " min ritmo  rápido"
                }else if(repsParse[repIndex].includes("moderado")){
                  map.distanciaZerar = map.distanciaTotal
                  ativo.text = parseInt(repsParse[repIndex]) + " min ritmo moderado"
                }else if(repsParse[repIndex].includes("lento")){
                   map.distanciaZerar = map.distanciaTotal
                   ativo.text = parseInt(repsParse[repIndex]) + " min ritmo lento"

                }
              if(parseInt(repsParse[repIndex]) <= tempoTotal){
              tempoTotal = 0
              repIndex++
              firstIndex = 0
              beep.play()
              }

            }
            if(repIndex == 0){

               if(repsParse[repIndex].includes("rápido")){
                  map.distanciaZerar = map.distanciaTotal
                  ativo.text = parseInt(repsParse[repIndex]) + " min ritmo rápido"           
                  if(parseInt(repsParse[repIndex]) <= tempoTotal){
                  tempoTotal = 0
                  repIndex++
                  beep.play()
                  firstIndex = 0
                  }
                }else if(repsParse[repIndex].includes("moderado")){
                  map.distanciaZerar = map.distanciaTotal
                  ativo.text = parseInt(repsParse[repIndex]) + " min ritmo moderado"         
                  if(parseInt(repsParse[repIndex]) <= tempoTotal){
                  tempoTotal = 0
                  repIndex++
                  beep.play()
                  }
                }else if(repsParse[repIndex].includes("lento")){
                  
                  map.distanciaZerar = map.distanciaTotal
                  ativo.text = parseInt(repsParse[repIndex]) + " min ritmo lento"
                  if(parseInt(repsParse[repIndex]) <= tempoTotal){
                  tempoTotal = 0
                  repIndex++
                  beep.play()
                  firstIndex = 0
                  }
                

                }else{
                  if(firstIndex == 0){
                  map.distanciaZerar += parseInt(repsParse[repIndex])
                  firstIndex++
                  }
                  ativo.text = parseInt(repsParse[repIndex]) + "m correr"
                  if(map.distanciaTotal >= map.distanciaZerar){
                    repIndex++
                    beep.play()
                    firstIndex = 0
                    tempoTotal = 0
                  }
                } 
            }
          }
          if(savedReps == undefined){
            ativo.text = "treino livre"
          }
          segundos++
          if(segundos >=60){
            segundos = 0
            minutos++
            tempoTotal++
          }
          if(minutos >=60){
            minutos = 0
            horas++

          }
          paceStatus = ((segundos / 60) + (minutos) + (horas * 60)) /  (map.distanciaTotal / 1000)
          if(horas < 10){
          horas = horas.toString().padStart(2, '0')
          }
          if(minutos < 10){
          minutos = minutos.toString().padStart(2, '0')
          }
          if(segundos < 10){
          segundos = segundos.toString().padStart(2, '0')
          }
      
          if(paceStatus >=2 && paceStatus <=100){
            pace.text = paceStatus.toFixed(2)+ " min/km"
          }else{
            pace.text = "0 min/km"
          }
          time.text = horas+":"+minutos+":"+segundos

        }
    }

    AppText{
      scale: 1.8 
      id: pace 
      text: "" 
      color:"black"
      font: robotoBold.font
      anchors.horizontalCenter: parent.horizontalCenter

    }
    AppText {
      scale: 1.8
      id: time 
      text: "" 
      color: "black"
      font: robotoBold.font
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.top: pace.bottom
    }AppText {
      scale: 1.8
      id: ativo 
      text: "" 
      color: "black"
      font: robotoBold.font
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.top: time.bottom
    }
    }

   IconButton{
      iconType: IconType.play 
      id: resumeRep  
      anchors.bottom: iniciarRep.top
      anchors.horizontalCenter: parent.horizontalCenter 
      anchors.horizontalCenterOffset: -25
      color: "green"
      visible: false
      scale: 2
      onClicked:{

        beep.play()
        timer.running = true
        if(stopRep.visible = false){
        var horariosInicio = storage.getValue("horarios-inicio")
        var horarioInicio = new Date() 
        var horarioFormatado = horarioInicio.toLocaleTimeString("pt-br")
        if(horariosInicio != undefined){
          horariosParse = JSON.parse(horariosInicio)

        }else{
          horariosParse = []
        }
        horariosParse.push(horarioFormatado);
        storage.setValue("horarios-inicio",JSON.stringify(horariosParse))

        }
       
        pauseRep.visible = true
        stopRep.visible = true
        map.coordinates = []
        map.distanciaTotal = 0
        resumeRep.visible = false
        map.lon1 = map.userPosition.coordinate.longitude
        map.lat1 = map.userPosition.coordinate.latitude 


      }


    }
   IconButton{
      iconType: IconType.pause
      id: pauseRep  
      anchors.bottom: iniciarRep.top
      anchors.horizontalCenter: parent.horizontalCenter 
      anchors.horizontalCenterOffset: -25
      color: "yellow"
      visible: false
      scale: 2
      onClicked:{
        beep.play()
        timer.running = false 

        var horariosInicio = storage.getValue("horarios-inicio")
        var horarioInicio = new Date() 
        var horarioFormatado = horarioInicio.toLocaleTimeString("pt-br")
        if(horariosInicio != undefined){
          var horariosParse = JSON.parse(horariosInicio)

        }else{
          horariosParse = []
        }
        horariosParse.push(horarioFormatado);
        storage.setValue("horarios-inicio",JSON.stringify(horariosParse))

        pauseRep.visible = false 
        resumeRep.visible = true
        resumeRep.anchors.horizontalCenterOffset = -25
      }


    }
   IconButton{
      iconType: IconType.stop 
      id: stopRep 
      anchors.horizontalCenterOffset: 25
      anchors.bottom: iniciarRep.top
      anchors.horizontalCenter: parent.horizontalCenter 
      color: "red"
      visible: false
      scale: 2
      onClicked:{
              timer.running = false
              beep.play()
              stopRep.visible = false
              var nova_data = new Date()
              var horario_formatado = nova_data.toLocaleTimeString("pt-br")
              var data_corrida = nova_data.toLocaleDateString("pt-br")
              var horariosSalvo = storage.getValue("horarios-fim")
              var datasCorrida = storage.getValue("datas-corrida")
              var distancia = storage.getValue("distancias")
              if(horariosSalvo){
                var horariosParse = JSON.parse(horariosSalvo)
                var datasParse = JSON.parse(datasCorrida)
                var distanciaParse = JSON.parse(distancia)

              }else{
                var horariosParse = [];
                var datasParse = []
                var distanciaParse = []
              }

              horariosParse.push(horario_formatado);
              datasParse.push(data_corrida);
              distanciaParse.push(map.distanciaTotal);
              storage.setValue("distancias",JSON.stringify(distanciaParse))
              storage.setValue("horarios-fim",JSON.stringify(horariosParse)); 
              storage.setValue("datas-corrida",JSON.stringify(datasParse));
              time.text = "00:00:00"
              distance.text = "0m"
              ativo.text = ""
              pace.text = ""
              map.lon1 = 0 
              map.lat1 = 0

              pauseRep.visible = false
              resumeRep.visible = true 
              resumeRep.anchors.horizontalCenterOffset = 0
      }

    }
    AppButton {
      text: "iniciar"
      id: iniciarRep
      anchors.bottom: parent.bottom
      anchors.horizontalCenter: parent.horizontalCenter 
      width: parent.width  
      radius: dp(20)
      backgroundColor: "dark cyan"
      backgroundColorPressed: "light blue"
      fontFamily: robotoBold.font 
      onClicked: {

        beep.play()
        pauseRep.visible = true 
        stopRep.visible = true
        iniciarRep.visible = false 
        var horariosInicio = storage.getValue("horarios-inicio")
        var horarioInicio = new Date() 
        var horarioFormatado = horarioInicio.toLocaleTimeString("pt-br")
        if(horariosInicio != undefined){
          var horariosParse = JSON.parse(horariosInicio)

        }else{
          horariosParse = []
        }
        horariosParse.push(horarioFormatado);
        storage.setValue("horarios-inicio",JSON.stringify(horariosParse))
        time.text = "00:00:00"
        distance.text = "0m"

        map.lon1 = map.userPosition.coordinate.longitude
        map.lat1 = map.userPosition.coordinate.latitude
        timer.running = true 
         

      }
  
      
    }
    }

      
    }
    NavigationItem {
      title: "treinamentos"
      iconType: IconType.calendar

      NavigationStack{

      AppPage{
        title: "treinamentos"
        
        Rectangle{
          id: "retangulo"
          anchors.top: parent.top 
          color:"dark gray"
          width: parent.width
          opacity: 0.7
          height: dp(30)
        }
        AppText{
          text: "  adicionar treinamento"
          anchors.top: retangulo.top
          anchors.bottom: retangulo.bottom
          font: roboto.font
          color: "black"
          fontSize: sp(25)
        }
      Rectangle{
        id: "retangulo2"
        anchors.top: retangulo.top
        color:"dark gray"
        width: parent.width
        opacity: 0.7
        height: dp(30)
        anchors.topMargin: dp(230)

      }
      AppText{
          text: "  lista de treinamentos"
          anchors.bottom: retangulo2.bottom
          anchors.top: retangulo2.top
          font: roboto.font
          color: "black"
          height: dp(30)
          fontSize: sp(25)

        }
      AppTextField{
        id: nomeEx
        anchors.top: retangulo.top
        width: retangulo.width 
        height: dp(40)
        anchors.topMargin: dp(40)
        placeholderColor: "gray"
        textColor: "white"
        underlineColor: "white"
        placeholderText: "nome do exercício"
        font: roboto.font

        

      }
      AppTextField {
        id: "inputReps"
        anchors.top: retangulo.top
        width: retangulo.width 
        height: dp(40)
        anchors.topMargin: dp(90)
        placeholderColor: "gray"
        textColor: "white"
        underlineColor: "white"
        placeholderText: "quantas repetições"
        font: roboto.font
        
      }
      AppButton {
        anchors.top: retangulo.top
        width: retangulo.width 
        height: dp(50)
        anchors.topMargin: dp(160)
        radius: dp(20)
        text: "adicionar treinamento"
        onClicked: {
        if(parseInt(inputReps.text) >= 1 && parseInt(inputReps.text) <=100){
          if(nomeEx.text !== ""){
          listaEx.model.append({ text: nomeEx.text+"<br/>"+inputReps.text+" Repetições" });
          nomeEx.text = ""
          nomeEx.placeholderText = "nome do exercício" 
          nomeEx.placeholderColor = "gray"
          inputReps.text = ""
          inputReps.placeholderText = "quantas repetições"
          inputReps.placeholderColor = "gray" 
          var savedData = [];
          for (var i = 0; i < listaEx.model.count; ++i) {
          savedData.push({ text: listaEx.model.get(i).text });
          }
          storage.setValue("listaExModelo", JSON.stringify(savedData))

          }else{
          nomeEx.placeholderText = "insira um nome" 
          nomeEx.placeholderColor = "red"
          }

        }
        else{
          inputReps.placeholderText = "somente valores entre 1 e 100 são válidos"
          inputReps.placeholderColor = "red"
        }
        }

        
      }
Popup {
    id: popup
    x: 50
    y: 150
    width: 300
    height: 400
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    background: Rectangle {
        border.color: "gray"
        radius: 20
        color: "black"
    }

    AppText {
        id: textoPopup
        text: ""
        color: "white"
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        font: roboto.font
    }

    ScrollView {
        anchors.fill: parent
        anchors.bottom: parent.bottom
        anchors.bottomMargin: dp(50)
        Column {
            anchors.top: parent.top
            anchors.topMargin: dp(50)
            width: parent.width

            Repeater {
                id: repeater
                model: textoPopup.text.substring(0, textoPopup.text.indexOf("R") - 1)

                delegate: Item {
                    width: parent.width
                    height: dp(50)

                    AppTextField {
                        id: irmao
                        width: parent.width / 2.5
                        placeholderColor: "gray"
                        height: dp(20)
                        textColor: "white"
                        underlineColor: "white"
                        placeholderText: "tempo em minutos"
                        font: roboto.font
                    }

                    AppSwitch {
                        width: parent.width / 7
                        anchors.left: irmao.right
                        height: dp(20)
                        id: trocar
                        onToggled: {
                            if (trocar.checked) {
                                irmao.placeholderText = "distancia em metros"
                                combo.visible = false
                            } else {
                                irmao.placeholderText = "tempo em minutos"
                                combo.visible = true
                            }
                        }
                    }

                    ComboBox {
                        id: combo
                        width: parent.width / 3.5
                        model: ["rápido", "moderado", "lento"]
                        visible: true
                        height: dp(20)
                        anchors.right: parent.right
                        anchors.top: irmao.top
                    }
                }
            }
        }
    }

    AppButton {
        anchors.bottom: parent.bottom
        width: parent.width
        height: dp(40)
        radius: dp(20)
        text: "Salvar e selecionar"
        backgroundColor: "gray"
        onClicked: {
            var salvarDados = []
            for (var i = 0; i < repeater.count; ++i) {
                var item = repeater.itemAt(i);

         var irmao = item.children[0]; // Assumindo que o primeiro filho é o AppTextField
            var trocar = item.children[1]; // Assumindo que o segundo filho é o AppSwitch
            var combo = item.children[2]; // Assumindo que o terceiro filho é o ComboBox

            // Obtenha os valores dos componentes
            var irmaoValue = irmao.text;
            var trocarValue = trocar.checked;
            var comboValue = combo.currentText;

                console.log("Item " + i + ": irmao =", irmaoValue, "trocar =", trocarValue, "combo =", comboValue);
            if(trocarValue == false){
              if(parseInt(irmaoValue)){
                salvarDados.push(irmaoValue+comboValue)

              }
            }
            else if(trocarValue == true){
              if(parseInt(irmaoValue)){
                salvarDados.push(irmaoValue)

              }
            }
            }

            if(salvarDados.length === repeater.count){
              storage.setValue("listaRpModelo",JSON.stringify(salvarDados))
              popup.close();

            }else{
              return
            }
            
        }
    }
}
    AppListView {
      id: listaEx
      anchors.top: retangulo2.bottom 
      width: retangulo2.width
      model: ListModel {}
      Component.onCompleted:{
            try{
            var savedData = storage.getValue("listaExModelo");

            var parsedData = JSON.parse(savedData);
            listaEx.model.clear();
            for (var i = 0; i < parsedData.length; ++i) {
                listaEx.model.append(parsedData[i]);
            }

          }
            catch(err){
              console.log("erro ao carregar",err.message)
            }
      }

      delegate: SwipeOptionsContainer {
        width: parent.width 
        height: 70
        rightOption: 
          SwipeButton {
                iconType: IconType.pencil
                height: parent.height 
                onClicked: {
                    popup.open()
                }
              }
        
            leftOption: SwipeButton {
                iconType: IconType.trash 
                backgroundColor: "red"
                height: parent.height 
                onClicked: {

                 var selectedIndex = model.index
                 listaEx.model.remove(selectedIndex);
                 var savedData = [];
                  for (var i = 0; i < listaEx.model.count; ++i) {
                  savedData.push({ text: listaEx.model.get(i).text });
                  }
                 storage.setValue("listaExModelo", JSON.stringify(savedData))
                 try{
                  storage.clearValue("listaRpModelo")
                 }catch(err){
                  console.log("nenhuma rep",err.message)
                 }


                }
            }
        

        Rectangle {
            id: itemRect
            width: parent.width
            height: 70
            color: "black"
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: model.text
                color: "white"
            }  
        MouseArea {
                anchors.fill: parent
                hoverEnabled: true
              
                onEntered: {
                    parent.color = "#a0a0a0";
                    var selectedIndex = model.index 
                    var selectedItemText = listaEx.model.get(selectedIndex).text
                    var repsText = selectedItemText.substring(selectedItemText.indexOf(">") + 1)
            textoPopup.text = repsText
                }
                onExited: {
                    parent.color = "black";
                }
            }
        }
      }
  
    }
}

}
      
    }
    
  }
  
}
