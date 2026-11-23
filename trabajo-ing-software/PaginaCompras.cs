using System;
using System.Web;
using System.Web.UI;

namespace trabajo_ing_software
{
    public class PaginaCompras : Page
    {
        protected bool PuedeGuardarCompras => Convert.ToString(Session["RolUsuario"]) == "Administrador"
            || Convert.ToString(Session["RolUsuario"]) == "Comprador";

        protected override void OnInit(EventArgs e)
        {
            if (Session["IdUsuario"] == null) { Response.Redirect("~/Login.aspx"); return; }
            if (!PuedeGuardarCompras && Convert.ToString(Session["RolUsuario"]) != "Contador")
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
