using System;
using System.Web;
using System.Web.UI;

namespace trabajo_ing_software
{
    public class PaginaVentas : Page
    {
        protected int UsuarioVenta { get; private set; }

        protected bool PuedeGuardarVentas
        {
            get
            {
                string rol = (Convert.ToString(Session["RolUsuario"]) ?? "").Trim();
                return EsRol(rol, "Administrador")
                    || EsRol(rol, "Administrador General")
                    || EsRol(rol, "Vendedor");
            }
        }

        protected bool EsBodegueroVentas => EsRol((Convert.ToString(Session["RolUsuario"]) ?? "").Trim(), "Bodeguero");

        protected override void OnInit(EventArgs e)
        {
            if (!int.TryParse(Convert.ToString(Session["IdUsuario"]), out int usuario) || usuario <= 0)
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            string rol = Convert.ToString(Session["RolUsuario"]).Trim();
            string pagina = System.IO.Path.GetFileNameWithoutExtension(AppRelativeVirtualPath);
            bool permitido = PuedeGuardarVentas
                || (pagina == "Despachos" && EsRol(rol, "Bodeguero"))
                || EsRol(rol, "Contador");
            if (!permitido) throw new HttpException(403, "Tu perfil no tiene acceso a esta pantalla de Ventas.");
            UsuarioVenta = usuario;
            ViewStateUserKey = Session.SessionID;
            base.OnInit(e);
        }

        protected void ExigirEscrituraVentas()
        {
            if (!PuedeGuardarVentas)
                throw new HttpException(403, "Tu perfil tiene acceso de consulta.");
        }

        private static bool EsRol(string actual, string esperado)
        {
            return string.Equals(actual, esperado, StringComparison.OrdinalIgnoreCase);
        }
    }
}
