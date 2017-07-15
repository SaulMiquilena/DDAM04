//
//  ViewController.swift
//  Ejercicio01Modulo4
//
//  Created by laboratorio on 6/4/17.
//  Copyright (c) 2017 ucla.dcty.fomento. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    
    //propiedades y atributos
    var err: Int?
    var valorusuario: String?
    var valorclave: String?
    var estadoSwitch: Int?
    
    @IBOutlet var txtUsuario: UITextField!
    @IBOutlet var txtClave: UITextField!
    @IBOutlet var mySwitch: UISwitch!
    
    var msgError = "Usuario y Clave No Registrado"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        mySwitch.addTarget(self, action: Selector("recordar:"), forControlEvents: UIControlEvents.ValueChanged);
        
        //Buscar si existe la tabla usuarios
        let (tables, err1) = SD.existingTables()
        self.err = err1
        if contains(tables, "usuarios") {
            //Eliminando la tabla usuarios en la BD SwiftData.sqlite
            //self.err = SD.deleteTable("usuarios")
            //println("Existe la tabla usuarios en la BD SwiftData.sqlite")
            
            //Buscando a usuario recordado
            //println("Buscando a usuario recordado")
            let (resulset, err2) = SD.executeQuery("SELECT * FROM usuarios where recordar = ? LIMIT 1", withArgs: [1])
            self.err = err2
            if err != nil {
                let errMsg = SD.errorMessageForCode(self.err!)
                println("Error buscando en la BD SwiftData.sqlite: "+errMsg)
            } else {
                //Recorremos el Resulset
                for row in resulset {
                    let valorusuario = row["usuario"]?.asString()!
                    let valorclave = row["clave"]?.asString()!
                    self.txtUsuario.text = valorusuario!
                    self.txtClave.text = valorclave!
                    mySwitch.setOn(true, animated:true)
                }
            }
        } else {
            println("No existe la tabla usuarios en la BD SwiftData.sqlite")
            self.err = SD.createTable("usuarios", withColumnNamesAndTypes: ["usuario": .StringVal,"clave": .StringVal,"recordar": .IntVal])
            if self.err == nil {
                println("Creada con éxito la tabla usuarios en la BD SwiftData.sqlite")
                //usuario y clave: admin, admin
                self.err = SD.executeChange("INSERT INTO usuarios (usuario, clave, recordar) VALUES (?,?,?)", withArgs: ["admin", "admin", 0])
                if self.err == nil {
                    println("agregado el usuario y clave")
                } else {
                    let errMsg = SD.errorMessageForCode(self.err!)
                    println("Error insertando en la tabla usuarios de la BD SwiftData.sqlite: "+errMsg)
                }
            } else {
                let errMsg = SD.errorMessageForCode(self.err!)
                println("Error creando la tabla usuarios de la BD SwiftData.sqlite: "+errMsg)
            }
            println("Ahora ya creamos la tabla...")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //acciones y metodos
    @IBAction func btnIngresar(sender: AnyObject) {
        //Validando Usuario
        println("Buscando a el Usuario")
        
        var url : String = "http://localhost/servidor-restful/Despachador.php?servicio=1&usuario="+txtUsuario.text+"&clave="+txtClave.text
        
        var endpoint = NSURL(string: url)
        var data = NSData(contentsOfURL: endpoint!)
        var parseError: NSError?
        
        if let json: NSDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary {
            println("Consumiendo el Servicio=1")
            let usuario = json["usuario"] as? NSString
            let clave = json["clave"] as? NSString
            
            if usuario == nil && clave == nil {
                mensaje(msgError);
            } else {
                let bienvenido = "Bienvenido"
                mensaje(bienvenido)
                if estadoSwitch == 1 {
                    //Insertando usuario y clave: txtUsuario, txtClave, recordar true
                    self.err = SD.executeChange("INSERT INTO usuarios (usuario, clave, recordar) VALUES (?,?,?)", withArgs: [txtUsuario.text, txtClave.text, 1])
                    if self.err == nil {
                        println("Recordado el usuario y clave")
                    } else {
                        let errMsg = SD.errorMessageForCode(self.err!)
                        println("Error insertando en la tabla usuarios de la BD SwiftData.sqlite: "+errMsg)
                    }
                } else {
                    //Insertando usuario y clave: txtUsuario, txtClave, recordar true
                    self.err = SD.executeChange("UPDATE usuarios SET recordar = ? WHERE usuario = ? AND clave = ?", withArgs: [0, txtUsuario.text, txtClave.text])
                    if self.err == nil {
                        println("usuario y clave no seran recordados")
                    } else {
                        let errMsg = SD.errorMessageForCode(self.err!)
                        println("Error insertando en la tabla usuarios de la BD SwiftData.sqlite: "+errMsg)
                    }
                }
            }
            
        } else {
            println("El Usuario no se encuentra registrado")
        }
    }
    
    @IBAction func btnLimpiar(sender: AnyObject) {
        println("Limpiar los datos");
        self.txtUsuario.text = "";
        self.txtClave.text = "";
        mySwitch.setOn(false, animated: true)
    }
    
    func recordar(mySwitch: UISwitch) {
        if mySwitch.on {
            estadoSwitch = 1;
            println("Activo")
        } else {
            estadoSwitch = 0;
            println("No Activo")
        }
    }
    
    func mensaje(msg: String){
        let msgA = msg
        //Creamos la ventana Alert //Instaciamos la clase UIAlertController
        let alertController = UIAlertController(title: "Mensaje", message: msgA, preferredStyle: .Alert)
        
        //Definimos la acción para el botón Cancelar de la ventana Alert
        let cancelAction = UIAlertAction(title: "Cancelar", style: .Cancel) { (action:UIAlertAction!) in
            println("CANCELAR: Limpiar los datos");
            self.txtUsuario.text = "";
            self.txtClave.text = "";
            self.mySwitch.setOn(false, animated: true);
        }
        
        //Adicionamos la acción cancelAction
        alertController.addAction(cancelAction)
        
        //Definimos la acción para el botón OK de la ventana Alert
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
            println("OK: Muy bien");
            self.txtUsuario.text = "";
            self.txtClave.text = "";
            self.mySwitch.setOn(false, animated: true);
        }
        
        //Adicionamos la acción OKAction
        alertController.addAction(OKAction)
        
        //Mostramos la ventana de Alert
        self.presentViewController(alertController, animated: true, completion:nil)
    }
}




