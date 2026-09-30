<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="trabajo_ing_software.Login" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Acceso al Sistema - Dermocosmética</title>
    <link href="Content/Estilos.css" rel="stylesheet" type="text/css" />
   
    <style>
        .login-wrapper {
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }
        .login-box {
            width: 100%;
            max-width: 420px;
            text-align: center;
        }
        .subtitulo {
            font-size: 14px;
            color: var(--color-secundario);
            margin-bottom: 25px;
            letter-spacing: 1px;
            text-transform: uppercase;
        }
    </style>
</head>

<body>
    <form id="form1" runat="server">
        <div class="login-wrapper">
            <div class="card-dermocosmetica login-box">
                <h1 style="margin-bottom: 5px;">DERMOCOSMÉTICA</h1>
                <p class="subtitulo">Ingreso al Sistema</p>

                <div style="text-align: left;">
                    <label>Correo Electrónico:</label>
                    <asp:TextBox ID="txtCorreo" runat="server" CssClass="input-dermo" placeholder="ejemplo@dermo.cl"></asp:TextBox>
                    
                    <label>Contraseña:</label>
                    <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="input-dermo" placeholder="••••••••"></asp:TextBox>
                </div>

                <asp:Button ID="btnLogin" runat="server" Text="Ingresar al Sistema →" CssClass="btn-principal" Width="100%" OnClick="btnLogin_Click" />
                
                <br /><br />
                <!-- Mensaje de error si falla la clave -->
                <asp:Label ID="lblMensaje" runat="server" ForeColor="#C0392B" Font-Size="13px"></asp:Label>
            </div>
        </div>
    </form>
</body>
</html>