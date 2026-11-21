using System;
using System.Web;
using System.Web.UI;

namespace trabajo_ing_software
{
    public class PaginaVentas : Page
    {
        protected int UsuarioVenta { get; private set; }

        protected override void OnInit(EventArgs e)
        {
            if (!int.TryParse(Convert.ToString(Session["IdUsuario"]), out int usuario) || usuario <= 0)
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            string rol = Convert.ToString(Session["RolUsuario"]).Trim();
            string pagina = System.IO.Path.GetFileNameWithoutExtension(AppRelativeVirtualPath);
            bool permitido = EsRol(rol, "Administrador") || EsRol(rol, "Vendedor")
                || (pagina == "Despachos" && EsRol(rol, "Bodeguero"))
                || (pagina == "ReporteVentas" && EsRol(rol, "Contador"));
            if (!permitido) throw new HttpException(403, "Tu perfil no tiene acceso a esta pantalla de Ventas.");
            UsuarioVenta = usuario;
            ViewStateUserKey = Session.SessionID;
            base.OnInit(e);
        }

        private static bool EsRol(string actual, string esperado)
        {
            return string.Equals(actual, esperado, StringComparison.OrdinalIgnoreCase);
        }
    }
}
