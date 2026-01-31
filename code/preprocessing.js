// PREPROCESADO DE DATOS ORIGINALES

// Fusionar ambos CSV en titanic_full

db.pass_info.aggregate([
    {
        $lookup: {
            from: "pass_ticket",
            localField: "PassengerId",
            foreignField: "PassengerId",
            as: "ticket_data",
        },
    },
    { $unwind: "$ticket_data" },
    {
        $project: {
            // quitamos _id
            _id: 0,
            PassengerId: 1,
            // campos de pass_info:
            Name: 1,
            Age: 1,
            Sex: 1,
            SibSp: 1,
            Parch: 1,
            // campos de pass_ticket:
            Ticket: "$ticket_data.Ticket",
            Fare: "$ticket_data.Fare",
            Pclass: "$ticket_data.Pclass",
            Embarked: "$ticket_data.Embarked",
            Survived: "$ticket_data.Survived",
            Cabin: "$ticket_data.Cabin",
        },
    },
    {
        $out: "titanic_full", // nueva colección con todos los datos
    },
]);

// Limpieza de valores undefined a null

db.titanic_full.updateMany(
    { Cabin: { $exists: false } },
    { $set: { Cabin: null } },
);

// Limpieza valores Embarked null => Valor 'N' para diferenciar entre personas sin puerta de embarque

db.titanic_full.updateMany(
    { Embarked: { $exists: false } },
    { $set: { Embarked: "N" } },
);

// Limpieza valores Age => Sustitucion de valores nulos por la media

var avgAge = db.titanic_full
    .aggregate([
        { $match: { Age: { $type: "double" } } },
        { $group: { _id: null, avgAge: { $avg: "$Age" } } },
    ])
    .toArray()[0].avgAge;

db.titanic_full.updateMany(
    {
        $or: [{ Age: { $exists: false } }, { Age: null }],
    },
    {
        $set: { Age: avgAge },
    },
);

// Normalizar los datos

// Age int32 --> Double
db.titanic_full.updateMany({ Age: { $ne: null } }, [
    { $set: { Age: { $toDouble: "$Age" } } },
]);

// Fare int32 --> Double
db.titanic_full.updateMany({ Fare: { $ne: null } }, [
    { $set: { Fare: { $toDouble: "$Fare" } } },
]);

// Ticket int32 --> String
db.titanic_full.updateMany({ Ticket: { $ne: null } }, [
    { $set: { Ticket: { $toString: "$Ticket" } } },
]);

// IMPORTACION DE DATOS PARA LAS CONSULTAS

// Creación de CSV Consulta 1: supervivientes_por_clase
db.titanic_full.aggregate([
    {
        $project: {
            _id: 0,
            PassengerId: 1,
            Name: 1,
            Sex: 1,
            Age: 1,
            Pclass: 1,
            Survived: 1,
        },
    },
    { $out: "supervivientes_por_clase" },
]);

// Creación de CSV Consulta 2: pasajeros_por_puerto_edad
db.titanic_full.aggregate([
    {
        $project: {
            _id: 0,
            PassengerId: 1,
            Name: 1,
            Sex: 1,
            Age: 1,
            Pclass: 1,
            Embarked: 1,
        },
    },
    { $out: "pasajeros_por_puerto_edad" },
]);

// Creación de CSV Consulta 3: mujeres_supervivientes_por_clase
db.titanic_full.aggregate([
    {
        $project: {
            _id: 0,
            PassengerId: 1,
            Name: 1,
            Sex: 1,
            Age: 1,
            Pclass: 1,
            Survived: 1,
        },
    },
    { $out: "mujeres_supervivientes_por_clase" },
]);

// Creación rango_edad y CSV Consulta 4: pasajeros_por_rango_edad

db.titanic_full.aggregate([
    {
        $addFields: {
            rango_edad: {
                $switch: {
                    branches: [
                        { case: { $lt: ["$Age", 13] }, then: "Infante" },
                        {
                            case: {
                                $and: [
                                    { $gte: ["$Age", 13] },
                                    { $lt: ["$Age", 20] },
                                ],
                            },
                            then: "Adolescente",
                        },
                        {
                            case: {
                                $and: [
                                    { $gte: ["$Age", 20] },
                                    { $lt: ["$Age", 40] },
                                ],
                            },
                            then: "Adulto_Joven",
                        },
                        {
                            case: {
                                $and: [
                                    { $gte: ["$Age", 40] },
                                    { $lt: ["$Age", 60] },
                                ],
                            },
                            then: "Adulto",
                        },
                        { case: { $gte: ["$Age", 60] }, then: "Senior" },
                    ],
                    default: "Desconocido",
                },
            },
        },
    },
    {
        $project: {
            _id: 0,
            rango_edad: 1,
            PassengerId: 1,
            Name: 1,
            Sex: 1,
            Age: 1,
            Pclass: 1,
            Survived: 1,
        },
    },
    { $out: "pasajeros_por_rango_edad" },
]);

// Creacion de CSV Consulta 5: pasajeros_por_puerto_supervivencia

db.titanic_full.aggregate([
    {
        $project: {
            _id: 0,
            embarked: "$Embarked",
            survived: "$Survived",
            passenger_id: { $toString: "$PassengerId" },
        },
    },
    { $out: "pasajeros_por_puerto_supervivencia" },
]);

// Creacion de atributo rango_edad y de CSV Consulta 6: pasajeros_por_clase_edad_supervivencia

db.titanic_full.aggregate([
    {
        $addFields: {
            rango_edad: {
                $switch: {
                    branches: [
                        { case: { $lt: ["$Age", 13] }, then: "Infante" },
                        {
                            case: {
                                $and: [
                                    { $gte: ["$Age", 13] },
                                    { $lt: ["$Age", 20] },
                                ],
                            },
                            then: "Adolescente",
                        },
                        {
                            case: {
                                $and: [
                                    { $gte: ["$Age", 20] },
                                    { $lt: ["$Age", 40] },
                                ],
                            },
                            then: "Adulto_Joven",
                        },
                        {
                            case: {
                                $and: [
                                    { $gte: ["$Age", 40] },
                                    { $lt: ["$Age", 60] },
                                ],
                            },
                            then: "Adulto",
                        },
                        { case: { $gte: ["$Age", 60] }, then: "Senior" },
                    ],
                    default: "Desconocido",
                },
            },
        },
    },
    {
        $project: {
            _id: 0,
            rango_edad: 1,
            PassengerId: 1,
            Pclass: 1,
            Survived: 1,
        },
    },
    { $out: "pasajeros_por_clase_edad_supervivencia" },
]);
