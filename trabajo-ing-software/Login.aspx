<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="trabajo_ing_software.Login" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="es">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Ingreso al Portal - Cosmetolog&iacute;a Profesional</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,500;0,600;0,700;1,400;1,500;1,600&family=Plus+Jakarta+Sans:wght@300;400;500;600;700&display=swap" rel="stylesheet" />
    <link href="Content/Estilos.css" rel="stylesheet" type="text/css" />
    <style>
        .login-main-wrapper {
            max-width: 1220px;
            margin: 35px auto 40px auto;
            padding: 0 20px;
        }

        .login-split-grid {
            display: grid;
            grid-template-columns: 1.05fr 1fr;
            gap: 28px;
            align-items: stretch;
        }

        /* Columna derecha con foto cosmetica */
        .hero-image-card {
            background: linear-gradient(180deg, rgba(0,0,0,0.05) 0%, rgba(0,0,0,0.35) 100%),
                        url('https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=900&q=80') center/cover no-repeat;
            border-radius: 26px;
            position: relative;
            padding: 30px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            min-height: 580px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.08);
        }

        .floating-quote-card {
            background-color: var(--color-blanco);
            border-radius: 20px;
            padding: 24px;
            box-shadow: 0 12px 30px rgba(0,0,0,0.15);
        }

        .features-grid-4 {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 18px;
            margin-top: 30px;
        }

        .feature-card-item {
            background-color: var(--color-blanco);
            border: 1px solid var(--color-borde-suave);
            border-radius: 18px;
            padding: 20px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.02);
        }

        .footer-dermo {
            background-color: #F3EFEA;
            border-top: 1px solid var(--color-borde-suave);
            margin-top: 60px;
            padding: 50px 40px 30px 40px;
        }

        .footer-grid {
            max-width: 1200px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: 2fr 1fr 1fr 1.5fr;
            gap: 40px;
        }

        @media (max-width: 900px) {
            .login-split-grid {
                grid-template-columns: 1fr;
            }
            .features-grid-4 {
                grid-template-columns: 1fr 1fr;
            }
            .footer-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <!-- HEADER GLOBAL -->
        <header class="top-header">
            <div class="brand-block">
                <span class="brand-logo">Dermo ERP</span>
                <span class="brand-sub">SISTEMA DE GESTI&Oacute;N COSMEC&Eacute;UTICA</span>
            </div>
            <nav>
                <ul class="nav-links-menu">
                    <li><span class="nav-item-link active">Portal de Acceso</span></li>
                    <li><span class="nav-item-link">Compras</span></li>
                    <li><span class="nav-item-link">Inventario</span></li>
                    <li><span class="nav-item-link">Ventas</span></li>
                    <li><span class="nav-item-link">Contabilidad</span></li>
                </ul>
            </nav>
            <div class="header-actions">
                <span class="pill-badge" style="font-size: 11px; padding: 6px 14px;">ERP Corporativo</span>
                <div class="user-avatar-btn" title="Acceso de Usuario">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                </div>
            </div>
        </header>

        <!-- SECCION PRINCIPAL-->
        <div class="login-main-wrapper">
            <div class="login-split-grid">
                
                <!-- COLUMNA IZQUIERDA: FORMULARIO DE ACCESO -->
                <div class="card-dermo-luxury" style="display: flex; flex-direction: column; justify-content: space-between;">
                    <div>
                        <div class="pill-badge" style="margin-bottom: 20px;">
                            &bull; ACCESO CORPORATIVO &middot; SISTEMA ERP
                        </div>

                        <h1 style="font-size: 34px; margin-bottom: 10px;">
                            Ingreso al <em style="font-family:'Playfair Display', Georgia, serif; font-style: italic; color: var(--color-acento);">Portal</em>
                        </h1>
                        <p class="text-muted" style="line-height: 1.6; margin-bottom: 28px;">
                            Bienvenido de nuevo. Ingrese sus credenciales corporativas para acceder a la gesti&oacute;n de compras, inventario, ventas y contabilidad.
                        </p>

                        <!-- CAMPO CORREO -->
                        <div class="form-group-dermo">
                            <label class="form-label-dermo">CORREO ELECTR&Oacute;NICO</label>
                            <div class="input-icon-wrapper">
                                <svg class="field-icon-svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path><polyline points="22,6 12,13 2,6"></polyline></svg>
                                <asp:TextBox ID="txtCorreo" runat="server" CssClass="input-pill-dermo input-with-icon" placeholder="usuario@dermo.cl"></asp:TextBox>
                            </div>
                        </div>

                        <!-- CAMPO CONTRASENA -->
                        <div class="form-group-dermo">
                            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
                                <label class="form-label-dermo" style="margin: 0;">CONTRASE&Ntilde;A</label>
                            </div>
                            <div class="input-icon-wrapper">
                                <svg class="field-icon-svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect><path d="M7 11V7a5 5 0 0 1 10 0v4"></path></svg>
                                <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="input-pill-dermo input-with-icon" placeholder="••••••••"></asp:TextBox>
                            </div>
                        </div>

                        <!-- OPCIONES DE SESION -->
                        <div style="display: flex; justify-content: space-between; align-items: center; margin: 20px 0 25px 0; font-size: 13px;">
                            <label style="display: flex; align-items: center; gap: 8px; cursor: pointer; color: var(--color-texto-suave);">
                                <input type="checkbox" checked="checked" style="accent-color: var(--color-acento);" /> Recordar sesi&oacute;n activa
                            </label>
                            <span style="color: var(--color-texto-suave); font-size: 12px; display: flex; align-items: center; gap: 5px;">
                                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path></svg>
                                Cifrado 256-bit
                            </span>
                        </div>

                        <!-- BOTON ACCESO -->
                        <asp:Button ID="btnLogin" runat="server" Text="Ingresar al Sistema" CssClass="btn-dermo-primary" Width="100%" OnClick="btnLogin_Click" />
                        
                        <!-- MENSAJE DE ERROR O VALIDACION -->
                        <asp:Label ID="lblMensaje" runat="server" ForeColor="#C0392B" Font-Size="13px" style="display: block; margin-top: 14px; text-align: center; font-weight: 500;"></asp:Label>
                    </div>

                    <div style="display: flex; justify-content: space-between; align-items: center; border-top: 1px solid var(--color-borde-suave); padding-top: 18px; margin-top: 25px; font-size: 11px; color: var(--color-texto-suave);">
                        <span style="display: flex; align-items: center; gap: 6px;">
                            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path></svg>
                            Protocolo de Seguridad Corporativa
                        </span>
                        <span>v2.4 SECURE</span>
                    </div>
                </div>

                <!-- COLUMNA DERECHA: TARJETA VISUAL DE ALTA COSMETICA -->
                <div class="hero-image-card">
                    <div style="text-align: right;">
                        <span class="pill-badge" style="background-color: rgba(255,255,255,0.92); backdrop-filter: blur(8px);">
                            &bull; COSMEC&Eacute;UTICA AVANZADA
                        </span>
                    </div>

                    <!-- TARJETA FLOTANTE INFERIOR -->
                    <div class="floating-quote-card">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; font-size: 11px; font-weight: 700; letter-spacing: 0.8px;">
                            <span style="color: var(--color-acento);">01 &middot; GESTI&Oacute;N INTEGRAL</span>
                            <span class="text-muted">Calidad Certificada</span>
                        </div>
                        <h3 style="font-size: 20px; line-height: 1.35; margin-bottom: 10px; color: var(--color-texto);">
                            &ldquo;Trazabilidad, precisi&oacute;n operativa y excelencia en cada proceso dermocosm&eacute;tico.&rdquo;
                        </h3>
                        <p class="text-muted" style="margin: 0 0 16px 0; line-height: 1.5; font-size: 12px;">
                            Plataforma unificada para el control de abastecimiento internacional, lotes bajo criterio FEFO, distribuci&oacute;n comercial y balance financiero.
                        </p>
                        <div style="display: flex; justify-content: space-between; align-items: center; font-size: 11px; font-weight: 600; color: var(--color-acento);">
                            <span>L&iacute;nea Dermocosm&eacute;tica Profesional</span>
                            <span style="color: var(--color-texto-suave); letter-spacing: 2px;">&bull;&bull;&bull;</span>
                        </div>
                    </div>
                </div>

            </div>

            <!-- CUADRICULA DE 4 TARJETAS RESUMEN DE MODULOS -->
            <div class="features-grid-4">
                <div class="feature-card-item">
                    <div style="font-size: 10px; font-weight: 700; letter-spacing: 1px; color: var(--color-texto-suave); margin-bottom: 6px;">01. ABASTECIMIENTO</div>
                    <div style="font-family: 'Playfair Display', Georgia, serif; font-size: 24px; font-weight: 700; color: var(--color-texto); margin-bottom: 4px;">Compras</div>
                    <div class="text-muted" style="font-size: 11px;">Laboratorios, importaci&oacute;n y &oacute;rdenes</div>
                </div>

                <div class="feature-card-item">
                    <div style="font-size: 10px; font-weight: 700; letter-spacing: 1px; color: var(--color-texto-suave); margin-bottom: 6px;">02. LOG&Iacute;STICA FEFO</div>
                    <div style="font-family: 'Playfair Display', Georgia, serif; font-size: 24px; font-weight: 700; color: var(--color-texto); margin-bottom: 4px;">Inventario</div>
                    <div class="text-muted" style="font-size: 11px;">Existencias por bodega y lotes</div>
                </div>

                <div class="feature-card-item">
                    <div style="font-size: 10px; font-weight: 700; letter-spacing: 1px; color: var(--color-texto-suave); margin-bottom: 6px;">03. COMERCIAL</div>
                    <div style="font-family: 'Playfair Display', Georgia, serif; font-size: 24px; font-weight: 700; color: var(--color-texto); margin-bottom: 4px;">Ventas</div>
                    <div class="text-muted" style="font-size: 11px;">Facturaci&oacute;n, clientes y despachos</div>
                </div>

                <div class="feature-card-item">
                    <div style="font-size: 10px; font-weight: 700; letter-spacing: 1px; color: var(--color-texto-suave); margin-bottom: 6px;">04. FINANZAS</div>
                    <div style="font-family: 'Playfair Display', Georgia, serif; font-size: 24px; font-weight: 700; color: var(--color-texto); margin-bottom: 4px;">Contabilidad</div>
                    <div class="text-muted" style="font-size: 11px;">Libro diario, cuentas y flujo de caja</div>
                </div>
            </div>

        </div>

        <!-- FOOTER CORPORATIVO OFICIAL -->
        <footer class="footer-dermo">
            <div class="footer-grid">
                <div>
                    <div class="brand-logo" style="margin-bottom: 8px;">Dermo ERP</div>
                    <p class="text-muted" style="max-width: 340px; line-height: 1.6; margin-bottom: 14px;">
                        Sistema integral de planificaci&oacute;n de recursos empresariales para la industria dermocosm&eacute;tica. Rigor operativo, trazabilidad y control financiero.
                    </p>
                    <div style="font-size: 10px; font-weight: 700; letter-spacing: 1.5px; color: var(--color-acento);">
                        GESTI&Oacute;N &amp; DISTRIBUCI&Oacute;N DERMOCOSM&Eacute;TICA
                    </div>
                </div>

                <div>
                    <div style="font-size: 11px; font-weight: 700; letter-spacing: 1px; margin-bottom: 14px;">M&Oacute;DULOS ERP</div>
                    <ul style="list-style: none; padding: 0; margin: 0; font-size: 12px; line-height: 2.2;" class="text-muted">
                        <li>Compras y Proveedores</li>
                        <li>Control de Inventario FEFO</li>
                        <li>Punto de Venta y Despachos</li>
                        <li>Contabilidad y Finanzas</li>
                    </ul>
                </div>

                <div>
                    <div style="font-size: 11px; font-weight: 700; letter-spacing: 1px; margin-bottom: 14px;">CAT&Aacute;LOGO</div>
                    <ul style="list-style: none; padding: 0; margin: 0; font-size: 12px; line-height: 2.2;" class="text-muted">
                        <li>S&eacute;rums Concentrados</li>
                        <li>Complejos Antioxidantes</li>
                        <li>Fotoprotecci&oacute;n Mineral</li>
                        <li>Cuidado Restaurador Nocturno</li>
                    </ul>
                </div>

                <div>
                    <div style="font-size: 11px; font-weight: 700; letter-spacing: 1px; margin-bottom: 14px;">CASA MATRIZ</div>
                    <div class="text-muted" style="font-size: 12px; line-height: 1.8;">
                        <div>Av. Libertador 4520, Piso 6</div>
                        <div>Centro Empresarial Corporativo</div>
                        <div>contacto@dermoerp.cl</div>
                        <div>+56 (2) 2890-3300</div>
                        <div style="margin-top: 10px; color: var(--color-acento); font-weight: 600; display: flex; align-items: center; gap: 5px;">
                            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg>
                            Est&aacute;ndar de Calidad GMP / ISO 22716
                        </div>
                    </div>
                </div>
            </div>

            <div style="max-width: 1200px; margin: 35px auto 0 auto; padding-top: 20px; border-top: 1px solid var(--color-borde-suave); display: flex; justify-content: space-between; align-items: center; font-size: 11px; color: var(--color-texto-suave); flex-wrap: wrap; gap: 15px;">
                <div>&copy; 2026 Dermo ERP &middot; Sistema de Gesti&oacute;n Empresarial. Todos los derechos reservados.</div>
                <div style="display: flex; gap: 20px;">
                    <a href="Privacidad.aspx" style="color: inherit; text-decoration: none;">Privacidad y Datos Personales</a>
                    <a href="Privacidad.aspx" style="color: inherit; text-decoration: none;">Derechos ARCO (Ley 19.628)</a>
                </div>
            </div>
        </footer>
    </form>
</body>
</html>