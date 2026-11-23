using System;
using System.Data;
using System.Text.RegularExpressions;
using trabajo_ing_software.CapaDatos;

namespace trabajo_ing_software.CapaNegocio
{
    public static class ComprasServicio
    {
        public static DataTable ListarMarcas()
        {
            return ComprasRepositorio.ListarMarcas();
        }

        public static DataRow ObtenerMarca(int idMarca)
        {
            if (idMarca <= 0)
                throw new ArgumentException("Identificador de marca inválido.");
            return ComprasRepositorio.ObtenerMarca(idMarca);
        }

        public static void GuardarMarca(int? idMarca, string nombre, string descripcion, bool activa)
        {
            string nombreLimpio = (nombre ?? string.Empty).Trim();
            string descLimpia = (descripcion ?? string.Empty).Trim();

            if (nombreLimpio.Length == 0)
                throw new ArgumentException("Ingresa el nombre de la marca.");
            if (nombreLimpio.Length > 100)
                throw new ArgumentException("El nombre de la marca no puede superar 100 caracteres.");
            if (descLimpia.Length > 255)
                throw new ArgumentException("La descripción no puede superar 255 caracteres.");

            ComprasRepositorio.GuardarMarca(idMarca, nombreLimpio, descLimpia, activa);
        }

        public static DataTable ListarLaboratorios(string filtro, string pais, string estado)
        {
            return ComprasRepositorio.ListarLaboratorios(
                (filtro ?? string.Empty).Trim(),
                (pais ?? string.Empty).Trim(),
                (estado ?? string.Empty).Trim());
        }

        public static bool ValidarRutChileno(string rut)
        {
            if (string.IsNullOrWhiteSpace(rut)) return false;

            string limpio = rut.Replace(".", "").Replace("-", "").Trim().ToUpperInvariant();
            if (limpio.Length < 7 || limpio.Length > 9) return false;

            string cuerpo = limpio.Substring(0, limpio.Length - 1);
            char dv = limpio[limpio.Length - 1];

            if (!long.TryParse(cuerpo, out long rutNumero) || rutNumero <= 0) return false;
            return Regex.IsMatch(cuerpo, @"^[0-9]+$") && dv == CalcularDigitoVerificador(cuerpo);
        }

        public static char CalcularDigitoVerificador(string cuerpo)
        {
            int suma = 0;
            int multiplicador = 2;
            for (int i = cuerpo.Length - 1; i >= 0; i--)
            {
                suma += (cuerpo[i] - '0') * multiplicador;
                multiplicador = (multiplicador == 7) ? 2 : multiplicador + 1;
            }
            int resto = 11 - (suma % 11);
            if (resto == 11) return '0';
            if (resto == 10) return 'K';
            return (char)('0' + resto);
        }

        public static bool ValidarEmail(string email)
        {
            if (string.IsNullOrWhiteSpace(email)) return false;
            return Regex.IsMatch(email.Trim(), @"^[^@\s]+@[^@\s]+\.[a-zA-Z]{2,}$");
        }
    }
}
