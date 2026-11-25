using System;
using System.Web;
using System.Web.UI;

namespace trabajo_ing_software
{
    public class PaginaCompras : Page
    {
        protected bool PuedeGuardarCompras
        {
            get
            {
                string rol = (Convert.ToString(Session["RolUsuario"]) ?? "").Trim();
                return string.Equals(rol, "Administrador", StringComparison.OrdinalIgnoreCase)
                    || string.Equals(rol, "Administrador General", StringComparison.OrdinalIgnoreCase)
                    || string.Equals(rol, "Comprador", StringComparison.OrdinalIgnoreCase);
            }
        }

        protected override void OnInit(EventArgs e)
        {
            if (Session["IdUsuario"] == null) { Response.Redirect("~/Login.aspx"); return; }
            string rol = (Convert.ToString(Session["RolUsuario"]) ?? "").Trim();
            if (!PuedeGuardarCompras && !string.Equals(rol, "Contador", StringComparison.OrdinalIgnoreCase))
                throw new HttpException(403, "Tu perfil no tiene acceso a Compras.");
            ViewStateUserKey = Session.SessionID;
            base.OnInit(e);
        }

        protected void ExigirEscrituraCompras()
        {
            if (!PuedeGuardarCompras) throw new HttpException(403, "Tu perfil tiene acceso de consulta.");
        }
    }
}
