using System;
using System.Security.Cryptography;

namespace trabajo_ing_software
{
    internal static class ClaveUsuario
    {
        internal const string Prefijo = "pbkdf2-sha256$";
        private const int Iteraciones = 600000;

        internal static string Crear(string clave)
        {
            byte[] sal = new byte[16];
            using (var rng = RandomNumberGenerator.Create()) rng.GetBytes(sal);
            using (var derivador = new Rfc2898DeriveBytes(clave, sal, Iteraciones, HashAlgorithmName.SHA256))
                return Prefijo + Convert.ToBase64String(sal) + "$" + Convert.ToBase64String(derivador.GetBytes(32));
        }

        internal static bool Verificar(string clave, string guardada)
        {
            if (string.IsNullOrEmpty(guardada)) return false;
            if (!guardada.StartsWith(Prefijo, StringComparison.Ordinal))
                return string.Equals(clave, guardada, StringComparison.Ordinal);
            string[] partes = guardada.Split('$');
            if (partes.Length != 3) return false;
            try
            {
                byte[] sal = Convert.FromBase64String(partes[1]), esperado = Convert.FromBase64String(partes[2]);
                if (sal.Length != 16 || esperado.Length != 32) return false;
                using (var derivador = new Rfc2898DeriveBytes(clave, sal, Iteraciones, HashAlgorithmName.SHA256))
                {
                    byte[] real = derivador.GetBytes(32);
                    int diferencia = 0;
                    for (int i = 0; i < real.Length; i++) diferencia |= real[i] ^ esperado[i];
                    return diferencia == 0;
                }
            }
            catch (FormatException) { return false; }
        }
    }
}
