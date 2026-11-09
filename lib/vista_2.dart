import 'package:flutter/material.dart';
import 'package:recordatorios_app/AppColors.dart';
import 'package:flutter/services.dart';

class Vista2 extends StatefulWidget {
  const Vista2({super.key});

  @override
  State<Vista2> createState() => _Vista2State();
}

class _Vista2State extends State<Vista2> {

  final TextEditingController horasInput = TextEditingController();
  final TextEditingController minutosInput = TextEditingController();
  final TextEditingController nombreInput = TextEditingController();

  // (Opcional pero muy importante) Liberas la memoria cuando la vista se destruye
  @override
  void dispose() {
    horasInput.dispose();
    minutosInput.dispose();
    super.dispose();
  }

  bool intervaloUnico = false; //


  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText, //esto es el texto que aparece dentro del cuadro de texto cuando no hay nada escrito
      hintStyle: TextStyle(color: AppColors.colorBase1),
      filled: true,
      fillColor: AppColors.colorBase4,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: AppColors.colorBase2, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: AppColors.colorBase2.withValues(alpha: 0.7),
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.white, width: 2.0),
      ),
    );
  }

  Widget _buildColumn() { //esto es un metodo que devuelve un widget, en este caso una columna con dos cuadros de texto y un titulo
    // no se usa un row antes porque queremos que los cuadros de texto se acomoden uno debajo del otro, y no uno al lado del otro
    return Column( //regresa columna pa q se acomoden los cuadros de texto uno debajo del otro, y no uno al lado del otro
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(30.0),
          decoration: BoxDecoration(
            color: AppColors.colorBase4,
            border: Border.all(color: AppColors.colorBase2, width: 2.0),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column ( //esto pa tener unatextfield dentro edl otro, container solo puede tener un child, por eso children
            children: [
          Text(
            'Create Custom Break',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.colorBase1,
            ),
          ),
            ]
          )
        ),
        const SizedBox(height: 16.0),
        Column(
          children: [
            TextField(
            style: TextStyle(color: AppColors.colorBase1),
                decoration: _inputDecoration('Nombre el recordatorio'),
                controller: nombreInput,
          )
          ],
        ),
        const SizedBox(height: 16.0),
        Row(
          children: [
            Expanded( //pa q el cuadro de texto se estire y ocupe todo el espacio disponible, sino se veria muy chiquito
              child: TextField(
                style: TextStyle(color: AppColors.colorBase1),
                decoration: _inputDecoration('horas'),
                controller: horasInput,
                keyboardType: TextInputType.number, 
                    // 2. Esto filtra y restringe para que solo acepte dígitos (números del 0 al 9)
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: TextField(
                style: TextStyle(color: AppColors.colorBase1),
                decoration: _inputDecoration('minutos'),
                controller: minutosInput,
                keyboardType: TextInputType.number, 
                    // 2. Esto filtra y restringe para que solo acepte dígitos (números del 0 al 9)
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,],
              ),
            ),
          ],
        ),

      const SizedBox(height: 16.0),
      // ROW DEL BOTON DEL TIPO
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Expanded(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(5.0), 
          decoration: BoxDecoration(
            color: !intervaloUnico ? AppColors.colorBase1 : AppColors.colorBase4, //AQUI ES EL BOTON Q CAMBIA COLORES
            //color: AppColors.colorBase4,
            border: Border.all(color: AppColors.colorBase2, width: 2.0),
            borderRadius: BorderRadius.circular(16.0),
          ),
         // child: Column ( //esto pa tener unatextfield dentro edl otro, container solo puede tener un child, por eso children
          //  children: [
          child: Text(
            'INTERVALO',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: !intervaloUnico ? AppColors.colorBase4 : AppColors.colorBase1,
            ),
          ),
        ),
        ),
        const SizedBox(width: 16.0),
        // 2. El Switch en el medio
      Transform.scale(
        scale: 1.2,
        child:
        Switch(
              value: intervaloUnico,
              activeThumbColor: AppColors.colorBase1,
              onChanged: (bool newValue) {
                setState(() {
                  intervaloUnico = newValue;
                  }
                );
              }
          ),
      ),
          const SizedBox(width: 16.0),
          Expanded(
          child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(5.0), 
          decoration: BoxDecoration(
            color: !intervaloUnico ? AppColors.colorBase4 : AppColors.colorBase1,
            border: Border.all(color: AppColors.colorBase2, width: 2.0),
            borderRadius: BorderRadius.circular(16.0),
          ),
         // child: Column ( //esto pa tener unatextfield dentro edl otro, container solo puede tener un child, por eso children
          //  children: [
          child: Text(
            'UNICO',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: !intervaloUnico ? AppColors.colorBase1 : AppColors.colorBase4,
              
            ),
          ),
        ),
        ),

            ] //children
         // )
        ),

      const SizedBox(height: 16.0),
      ElevatedButton(
        /*
        stylefrom
        backgroundColor: color del fondo.
foregroundColor: color del texto y del icono.
padding: espacio interno.
shape: forma, por ejemplo bordes redondeados.
elevation: altura de la sombra.
minimumSize: tamaño mínimo del botón
        */ 
      onPressed: () {

        if (horasInput.text.trim().isEmpty) {
          horasInput.text = '0';
        }
        if (minutosInput.text.trim().isEmpty) {
          minutosInput.text = '0';
        }
        String tipoBreak = !intervaloUnico ? "intervalo" : "Unico";
        print(tipoBreak);

      if (nombreInput.text.trim().isEmpty){
        print('CAMPOS VACIOS');
      }
        print('horas: ${horasInput.text}'); //o uso eso o uso +
        print('minutos: ${minutosInput.text}'); //o uso eso o uso +
        print('nombre: ${nombreInput.text}'); //o uso eso o uso +
        //q salga un mesaje de 'recordatorio creado con exito' 
        //q se borre dsps de escribir
        horasInput.clear(); //pa q queden vacios
        minutosInput.clear();
        nombreInput.clear();
      },
      style: ElevatedButton.styleFrom( //EL STYLEFROM es 
      backgroundColor: AppColors.colorBase1, // O el color que prefieras de tu app
      foregroundColor: AppColors.colorBase2,
      padding: const EdgeInsets.symmetric(vertical: 16), //esto es pa q se centre
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
        ),
        child: const Text(
          'Create Break',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),


      ],
    );
  }

  Widget _buildPanel(Widget child) { //esto es un metodo que devuelve un widget, en este caso un contenedor con un borde y un color de fondo, y adentro el widget que le pasemos como parametro
    //el child es el widget que le pasamos como parametro, en este caso la columna con los cuadros de texto y el titulo
    return Container( //pa no escribir el container varias veces
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.colorBase5,
        border: Border.all(color: AppColors.colorBase2, width: 2.0),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) { //esto es el metodo que construye la interfaz de usuario, en este caso un scaffold con un body que contiene un padding y adentro un row o una columna dependiendo del ancho de la pantalla
    final anchoPantalla = MediaQuery.of(context).size.width;

    return Scaffold( //esto es un widget que nos da una estructura basica para nuestra app, con un appbar, un body, un drawer, etc
      backgroundColor: AppColors.colorBase3,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: anchoPantalla < 600
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    _buildPanel(_buildColumn()),
                    const SizedBox(height: 16.0),
                    _buildPanel(const Text('Contenido de la Vista 2')),
                  ],
                ),
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildPanel(_buildColumn())),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: _buildPanel(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(30.0),
                            decoration: BoxDecoration(
                              color: AppColors.colorBase4,
                              border: Border.all(
                                color: AppColors.colorBase2,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Text(
                              'Create Custom Break',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.colorBase1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          const Text('Contenido de la Vista 2'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
