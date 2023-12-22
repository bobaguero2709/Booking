//
//  main.swift
//  Booking
//
//  Created by Robert Aguero on 12/20/23.
//

import Foundation

//Mark : Client
struct Client {
    var name: String
    var age: Int
    var height: Double // height in cm

    init(name: String, age: Int, height: Double) {
        self.name = name
        self.age = age
        self.height = height
    }
}

extension Client:Equatable{
    static func == (lhs:Client,rhs:Client)->Bool{
        return  
            lhs.name.lowercased() == rhs.name.lowercased() &&
            lhs.age == rhs.age &&
            lhs.height == rhs.height
    }
}

//Mark:Reservation
struct Reservation {
    var uniqueId: String
    var hotelName: String
    var clientList: [Client]
    var duration: Int //duration in days
    var price: Double
    var includeBreakfast: Bool
    
    init(uniqueId: String, hotelName: String, clientList: [Client], duration: Int, price: Double, includeBreakfast: Bool) {
        self.uniqueId = uniqueId
        self.hotelName = hotelName
        self.clientList = clientList
        self.duration = duration
        self.price = price
        self.includeBreakfast = includeBreakfast
    }
}

extension Reservation:Equatable{
    static func == (lhs:Reservation,rhs:Reservation)->Bool{
        return
            lhs.duration == rhs.duration &&
            lhs.includeBreakfast == rhs.includeBreakfast &&
            lhs.price == rhs.price
        
    }
}

enum ReservationError: Error {
    case sameId
    case reservationClientFound
    case reservationNotFound
    case invalidDuration
}

enum GeneralError: Error {
    case invalidNumber
}

// Mark
class HotelReservationManager{
    var reservationList: [Reservation]
    var basePricePerClient: Double
    var feeBreakfast: Double
    init(){
        reservationList = []
        basePricePerClient = 30
        feeBreakfast = 1.25
    }
    
    func createReservation(reservation:Reservation) throws ->Reservation{
        var newReservation = reservation
        
        /*
        guard reservationList.filter({$0.uniqueId == newReservation.uniqueId}).count > 0 && reservationList.count > 0 else {
            throw ReservationError.sameId
        }
         */
        
        if(newReservation.duration<=0){
            throw ReservationError.invalidDuration
        }
        
        //We need find every client in new reservation in every client list in reservationList save.
        for client in newReservation.clientList {
            for r in reservationList {
                for clientInReservation in r.clientList {
                    if(client == clientInReservation){
                        throw ReservationError.reservationClientFound
                    }
                }
            }
        }
        
        newReservation.uniqueId = String(Date().timeIntervalSince1970)
        
        if(reservation.includeBreakfast){
            //We need validate if duration is a number valid
            newReservation.price = Double(newReservation.clientList.count) * basePricePerClient * Double(newReservation.duration) * feeBreakfast
        }else{
            newReservation.price = Double(newReservation.clientList.count) * basePricePerClient * Double(newReservation.duration)
        }
        
        reservationList.append(newReservation)
        
        return newReservation
        
    }
    
    func cancelReservation(idReservation:String) throws ->[Reservation]{
        guard reservationList.filter({$0.uniqueId == idReservation}).count > 0 else{
            throw ReservationError.reservationNotFound
        }
        let newReservationList = reservationList.filter({$0.uniqueId != idReservation})
        
        reservationList = newReservationList
        
        return reservationList
    }
    
    func allReservations()->[Reservation]{
        return reservationList
    }
}

var newHotelReservationManager = HotelReservationManager()

func testAddReservation(reservation:Reservation) -> String{
    var newId:String
    do{
        let reservationNew = try newHotelReservationManager.createReservation(reservation:reservation)
            assert(newHotelReservationManager.reservationList.count > 0)
        print("\n Reservación creada con éxito \n",newHotelReservationManager.allReservations())
            newId = reservationNew.uniqueId
            return newId
            
        }catch ReservationError.sameId{
            print("\n El identificador ya existe \n")
            return ""
            
        }catch ReservationError.reservationClientFound{
            print("\n El Cliente ya está en otra reservación \n")
            return ""
        }catch{
            print("\n Error desconocido \n")
            return ""
        }
    
}

func testCancelReservation(idReservation:String) -> Bool{
    do{
        let currentReservationList = try newHotelReservationManager.cancelReservation(idReservation: idReservation)
            assert(currentReservationList.filter({$0.uniqueId == idReservation}).count == 0)
            print("\n Reservación cancelada con éxito",newHotelReservationManager.allReservations())
            return true
        }catch ReservationError.reservationNotFound{
            print("\n La reservación no existe")
            return false
            
        }catch{
            print("Error desconocido")
            return false
        }
    
}

func testReservationPrice(reservation1: Reservation,reservation2: Reservation)->Bool{
    print("\n Reservation price 1: \n \(reservation1.price)")
    print("\n Reservation price 2: \n \(reservation2.price)")
    return reservation1 == reservation2 // it is possible because equatable is defined with parameters that include price
}

var newReservation:Reservation
var client1:Client
var client2:Client
client1 = .init(name:"Peter Parker",age: 28,height: 172)
client2 = .init(name: "Mary Jane", age: 29, height: 168)
newReservation = .init(uniqueId: "0", hotelName: "Melia Castilla", clientList: [client1,client2], duration: 1, price: 0, includeBreakfast: false)

var newReservation1:Reservation
var client3:Client
var client4:Client
client3 = .init(name:"Bruce Banner",age: 47,height: 190)
client4 = .init(name: "Betty Ross", age: 46, height: 154)
newReservation1 = .init(uniqueId: "0", hotelName: "Melia Castilla", clientList: [client3,client4], duration: 5, price: 0, includeBreakfast: true)

let newId = testAddReservation(reservation: newReservation)
assert(!newId.isEmpty)
let newId2 = testAddReservation(reservation: newReservation1)
assert(!newId2.isEmpty)

//Test Cancel First Reservation
testCancelReservation(idReservation:newId)

//Test cancel not found
testCancelReservation(idReservation:"6215362156321.213213")

testAddReservation(reservation: newReservation)

var newReservation3:Reservation
var client5:Client
var client6:Client
var client7:Client
client5 = .init(name:"Sue Storm",age: 35,height: 184)
client6 = .init(name: "Betty Brandt", age: 35, height: 168)
client7 = .init(name: "Stephen Strange", age: 35, height: 168)
newReservation3 = .init(uniqueId: "0", hotelName: "Melia Castilla", clientList: [client5,client6,client7], duration: 30, price: 0, includeBreakfast: true)

var newReservation4:Reservation
var client8:Client
var client9:Client
var client10:Client
client8 = .init(name:"Scott Summers",age: 47,height: 190)
client9 = .init(name: "Loki Laufeyson", age: 46, height: 154)
client10 = .init(name: "Jessica Jones", age: 46, height: 154)
newReservation4 = .init(uniqueId: "0", hotelName: "Melia Castilla", clientList: [client8,client9,client10], duration: 30, price: 0, includeBreakfast: true)

var newReservation5:Reservation
var client11:Client
var client12:Client
var client13:Client
client11 = .init(name:"Pepper Potsss",age: 47,height: 190)
client12 = .init(name: "Warren Worthington", age: 46, height: 154)
client13 = .init(name: "Doctor Doom", age: 46, height: 154)
newReservation5 = .init(uniqueId: "0", hotelName: "Melia Castilla", clientList: [client11,client12,client13], duration: 30, price: 0, includeBreakfast: false)


let newId3 = testAddReservation(reservation: newReservation3)
assert(!newId3.isEmpty)

let newId4 = testAddReservation(reservation: newReservation4)
assert(!newId4.isEmpty)

let newId5 = testAddReservation(reservation: newReservation5)
assert(!newId5.isEmpty)

// Same kind of reservation
print("Los precios de estas reservaciones son iguales: \(testReservationPrice(reservation1: newHotelReservationManager.reservationList[2], reservation2: newHotelReservationManager.reservationList[3]))")
// complete different reservation
print("Los precios de estas reservaciones son iguales: \(testReservationPrice(reservation1: newHotelReservationManager.reservationList[0], reservation2: newHotelReservationManager.reservationList[1]))")
// same duration and clients total but without breakfast, price different
print("Los precios de estas reservaciones son iguales: \(testReservationPrice(reservation1: newHotelReservationManager.reservationList[3], reservation2: newHotelReservationManager.reservationList[4]))")
