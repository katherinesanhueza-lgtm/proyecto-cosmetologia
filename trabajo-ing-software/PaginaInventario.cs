using System;
using System.Web;
using System.Web.UI;

namespace trabajo_ing_software
{
    public class PaginaInventario : Page
    {
        protected int UsuarioInventario { get; private set; }

        protected override void OnInit(EventArgs e)
        {
            if (!int.TryParse(Convert.ToString(Session["IdUsuario"]), out int usuario) || usuario <= 0)
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            string rol = Convert.ToString(Session["RolUsuario"]).Trim().ToUpperInvariant();
            string seccion = Request.QueryString["m"] ?? "productos";
            bool gestion = AppRelativeVirtualPath.EndsWith("/Gestion.aspx", StringComparison.OrdinalIgnoreCase);
            bool soloConsulta = !gestion || seccion == "historial" || seccion == "alertas" || seccion == "reportes";
            bool autorizado = rol == "ADMINISTRADOR" || rol == "BODEGUERO"
                || (soloConsulta && (rol == "COMPRADOR" || rol == "VENDEDOR" || rol == "CONTADOR"));
            if (!autorizado) throw new HttpException(403, "Tu perfil no tiene acceso a esta sección de Inventario.");

            UsuarioInventario = usuario;
            ViewStateUserKey = Session.SessionID;
            base.OnInit(e);
        }
    }
}
