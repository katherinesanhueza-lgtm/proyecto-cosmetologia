using System;
using System.Data;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using trabajo_ing_software.CapaDatos;

namespace trabajo_ing_software.CapaNegocio
{
    public static class ProteccionDatosServicio
    {
        public static DataTable ListarClientes()
        {
            return ProteccionDatosRepositorio.ListarClientesParaPrivacidad();
        }

        public static string ExportarFichaPersonalJson(int idCliente)
        {
            if (idCliente <= 0)
                throw new ArgumentException("Selecciona un cliente válido.");

            DataRow fila = ProteccionDatosRepositorio.ObtenerFichaCliente(idCliente);
            if (fila == null)
                throw new InvalidOperationException("No se encontró el registro del cliente seleccionado.");

            var documento = new JObject
            {
                ["normativa"] = "Ley N° 19.628 / Ley N° 21.719 sobre Protección de la Vida Privada (Chile)",
                ["fechaEmision"] = DateTime.Now.ToString("dd/MM/yyyy HH:mm"),
                ["titular"] = new JObject
                {
                    ["idCliente"] = Convert.ToInt32(fila["IdCliente"]),
                    ["rut"] = Convert.ToString(fila["Rut"]),
                    ["nombre"] = Convert.ToString(fila["Nombre"]),
                    ["razonSocial"] = Convert.ToString(fila["RazonSocial"]),
                    ["categoria"] = Convert.ToString(fila["Categoria"]),
                    ["giro"] = Convert.ToString(fila["Giro"]),
                    ["direccion"] = Convert.ToString(fila["Direccion"]),
                    ["contacto"] = Convert.ToString(fila["Contacto"]),
                    ["correo"] = Convert.ToString(fila["Correo"]),
                    ["telefono"] = Convert.ToString(fila["Telefono"]),
                    ["activo"] = Convert.ToInt32(fila["Activo"]) == 1
                }
            };

            return documento.ToString(Formatting.Indented);
        }

        public static void AnonimizarClienteInactivo(int idCliente)
        {
            if (idCliente <= 0)
                throw new ArgumentException("Selecciona un cliente válido.");

            int afectadas = ProteccionDatosRepositorio.AnonimizarClienteInactivo(idCliente);
            if (afectadas != 1)
                throw new InvalidOperationException("Solo es posible anonimizar clientes en estado Inactivo. Desactiva primero la ficha en el módulo de Clientes.");
        }
    }
}
