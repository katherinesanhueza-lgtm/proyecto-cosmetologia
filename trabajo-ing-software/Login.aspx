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
                <span class="brand-logo">NOMBRE</span>
                <span class="brand-sub">COSMETOLOG&Iacute;A PROFESIONAL</span>
            </div>
            <nav>
                <ul class="nav-links-menu">
                    <li><a href="#" class="nav-item-link active">Inicio</a></li>
                    <li><a href="#" class="nav-item-link">Tratamientos</a></li>
                    <li><a href="#" class="nav-item-link">Productos</a></li>
                    <li><a href="#" class="nav-item-link">Nosotros</a></li>
                    <li><a href="#" class="nav-item-link">Contacto</a></li>
                </ul>
            </nav>
            <div class="header-actions">
                <button type="button" class="header-icon-btn" title="Buscar">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                </button>
                <button type="button" class="btn-header-agendar">Agendar Cita</button>
                <div class="user-avatar-btn" title="Usuario">
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
                            &bull; PORTAL EXCLUSIVO &middot; CLIENTES
                        </div>

                        <h1 style="font-size: 34px; margin-bottom: 10px;">
                            Ingreso al <em style="font-family:'Playfair Display', Georgia, serif; font-style: italic; color: var(--color-acento);">Portal</em>
                        </h1>
                        <p class="text-muted" style="line-height: 1.6; margin-bottom: 28px;">
                            Bienvenido de nuevo. Acceda a sus tratamientos activos, citas cl&iacute;nicas y prescripciones cosmec&eacute;uticas personalizadas.
                        </p>

                        <!-- CAMPO CORREO -->
                        <div class="form-group-dermo">
                            <label class="form-label-dermo">CORREO ELECTR&Oacute;NICO</label>
                            <div class="input-icon-wrapper">
                                <svg class="field-icon-svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path><polyline points="22,6 12,13 2,6"></polyline></svg>
                                <asp:TextBox ID="txtCorreo" runat="server" CssClass="input-pill-dermo input-with-icon" placeholder="paciente@nombrecosmetologia.com" Text="admin@dermo.cl"></asp:TextBox>
                            </div>
                        </div>

                        <!-- CAMPO CONTRASENA -->
                        <div class="form-group-dermo">
                            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
                                <label class="form-label-dermo" style="margin: 0;">CONTRASE&Ntilde;A</label>
                                <a href="#" style="font-size: 12px; color: var(--color-texto-suave); text-decoration: none;">&iquest;Olvid&oacute; su clave?</a>
                            </div>
                            <div class="input-icon-wrapper">
                                <svg class="field-icon-svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect><path d="M7 11V7a5 5 0 0 1 10 0v4"></path></svg>
                                <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="input-pill-dermo input-with-icon" placeholder="••••••••" Text="123456"></asp:TextBox>
                            </div>
                        </div>

                        <!-- OPCIONES DE SESION -->
                        <div style="display: flex; justify-content: space-between; align-items: center; margin: 20px 0 25px 0; font-size: 13px;">
                            <label style="display: flex; align-items: center; gap: 8px; cursor: pointer; color: var(--color-texto-suave);">
                                <input type="checkbox" checked="checked" style="accent-color: var(--color-acento);" /> Recordar sesi&oacute;n m&eacute;dica
                            </label>
                            <span style="color: var(--color-texto-suave); font-size: 12px; display: flex; align-items: center; gap: 5px;">
                                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path></svg>
                                Cifrado 256-bit
                            </span>
                        </div>

                        <!-- BOTON ACCESO -->
                        <asp:Button ID="btnLogin" runat="server" Text="Acceder al Expediente →" CssClass="btn-dermo-primary" Width="100%" OnClick="btnLogin_Click" />
                        
                        <!-- MENSAJE DE ERROR O VALIDACION -->
                        <asp:Label ID="lblMensaje" runat="server" ForeColor="#C0392B" Font-Size="13px" style="display: block; margin-top: 14px; text-align: center; font-weight: 500;"></asp:Label>

                        <div style="text-align: center; margin-top: 25px;">
                            <a href="#" style="font-size: 12px; color: var(--color-acento); text-decoration: none; font-weight: 600;">
                                &iquest;A&uacute;n no inici&oacute; su tratamiento profesional? Solicitar diagn&oacute;stico inicial
                            </a>
                        </div>
                    </div>

                    <div style="display: flex; justify-content: space-between; align-items: center; border-top: 1px solid var(--color-borde-suave); padding-top: 18px; margin-top: 25px; font-size: 11px; color: var(--color-texto-suave);">
                        <span style="display: flex; align-items: center; gap: 6px;">
                            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path></svg>
                            Protocolo de Confidencialidad M&eacute;dica
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
                            <span style="color: var(--color-acento);">01 &middot; PRINCIPIO ACTIVO</span>
                            <span class="text-muted">Eficacia Comprobada</span>
                        </div>
                        <h3 style="font-size: 20px; line-height: 1.35; margin-bottom: 10px; color: var(--color-texto);">
                            &ldquo;Ciencia, armon&iacute;a sensorial y resultados visibles en cada estrato cut&aacute;neo.&rdquo;
                        </h3>
                        <p class="text-muted" style="margin: 0 0 16px 0; line-height: 1.5; font-size: 12px;">
                            Formulaciones biocompatibles dise&ntilde;adas meticulosamente bajo estrictos est&aacute;ndares de dermatolog&iacute;a restaurativa y alta cosm&eacute;tica biol&oacute;gica.
                        </p>
                        <div style="display: flex; justify-content: space-between; align-items: center; font-size: 11px; font-weight: 600; color: var(--color-acento);">
                            <span>L&iacute;nea Hidro-Nutritiva Bioactiva</span>
                            <span style="color: var(--color-texto-suave); letter-spacing: 2px;">&bull;&bull;&bull;</span>
                        </div>
                    </div>
                </div>

            </div>

            <!-- CUADRICULA DE TARJETAS RESUMEN DE PROTOCOLO -->
            <div class="features-grid-4">
                <div class="feature-card-item">
                    <div style="font-size: 10px; font-weight: 700; letter-spacing: 1px; color: var(--color-texto-suave); margin-bottom: 6px;">01. PROTOCOLOS</div>
                    <div style="font-family: 'Playfair Display', Georgia, serif; font-size: 24px; font-weight: 700; color: var(--color-texto); margin-bottom: 4px;">100%</div>
                    <div class="text-muted" style="font-size: 11px;">Personalizados por fototipo</div>
                </div>

                <div class="feature-card-item">
                    <div style="font-size: 10px; font-weight: 700; letter-spacing: 1px; color: var(--color-texto-suave); margin-bottom: 6px;">02. SEGUIMIENTO</div>
                    <div style="font-family: 'Playfair Display', Georgia, serif; font-size: 24px; font-weight: 700; color: var(--color-texto); margin-bottom: 4px;">Digital</div>
                    <div class="text-muted" style="font-size: 11px;">Historial dermo-cosm&eacute;tico</div>
                </div>

                <div class="feature-card-item">
                    <div style="font-size: 10px; font-weight: 700; letter-spacing: 1px; color: var(--color-texto-suave); margin-bottom: 6px;">03. ASISTENCIA</div>
                    <div style="font-family: 'Playfair Display', Georgia, serif; font-size: 24px; font-weight: 700; color: var(--color-texto); margin-bottom: 4px;">24 / 7</div>
                    <div class="text-muted" style="font-size: 11px;">Equipo t&eacute;cnico profesional</div>
                </div>
            </div>

        </div>

        <!-- FOOTER CLINICO OFICIAL -->
        <footer class="footer-dermo">
            <div class="footer-grid">
                <div>
                    <div class="brand-logo" style="margin-bottom: 8px;">NOMBRE</div>
                    <p class="text-muted" style="max-width: 340px; line-height: 1.6; margin-bottom: 14px;">
                        Cosmetolog&iacute;a m&eacute;dica y alta est&eacute;tica avanzada. Rigor cient&iacute;fico, armon&iacute;a integral y formulaciones sensoriales de excelencia.
                    </p>
                    <div style="font-size: 10px; font-weight: 700; letter-spacing: 1.5px; color: var(--color-acento);">
                        DERMATOLOG&Iacute;A &amp; CUIDADO DE LA PIEL
                    </div>
                </div>

                <div>
                    <div style="font-size: 11px; font-weight: 700; letter-spacing: 1px; margin-bottom: 14px;">TRATAMIENTOS</div>
                    <ul style="list-style: none; padding: 0; margin: 0; font-size: 12px; line-height: 2.2;" class="text-muted">
                        <li>Diagn&oacute;stico Cut&aacute;neo Digital</li>
                        <li>Bioestimulaci&oacute;n Lum&iacute;nica</li>
                        <li>Terapia Regenerativa Facial</li>
                        <li>Protocolos Pre &amp; Post Quir&uacute;rgicos</li>
                    </ul>
                </div>

                <div>
                    <div style="font-size: 11px; font-weight: 700; letter-spacing: 1px; margin-bottom: 14px;">COSMEC&Eacute;UTICA</div>
                    <ul style="list-style: none; padding: 0; margin: 0; font-size: 12px; line-height: 2.2;" class="text-muted">
                        <li>S&eacute;rums Concentrados</li>
                        <li>Complejos Antioxidantes</li>
                        <li>Fotoprotecci&oacute;n Mineral</li>
                        <li>Cuidado Restaurador Nocturno</li>
                    </ul>
                </div>

                <div>
                    <div style="font-size: 11px; font-weight: 700; letter-spacing: 1px; margin-bottom: 14px;">CL&Iacute;NICA CENTRAL</div>
                    <div class="text-muted" style="font-size: 12px; line-height: 1.8;">
                        <div>Av. Libertador 4520, Piso 6</div>
                        <div>Distrito M&eacute;dico Especializado</div>
                        <div>clinica@nombrecosmetologia.com</div>
                        <div>+56 (11) 4890-3300</div>
                        <div style="margin-top: 10px; color: var(--color-acento); font-weight: 600; display: flex; align-items: center; gap: 5px;">
                            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"></polyline></svg>
                            Certificaci&oacute;n Est&eacute;tica M&eacute;dica
                        </div>
                    </div>
                </div>
            </div>

            <div style="max-width: 1200px; margin: 35px auto 0 auto; padding-top: 20px; border-top: 1px solid var(--color-borde-suave); display: flex; justify-content: space-between; align-items: center; font-size: 11px; color: var(--color-texto-suave); flex-wrap: wrap; gap: 15px;">
                <div>&copy; 2024 NOMBRE Cosmetolog&iacute;a Profesional. Todos los derechos reservados.</div>
                <div style="display: flex; gap: 20px;">
                    <a href="#" style="color: inherit; text-decoration: none;">Privacidad M&eacute;dica</a>
                    <a href="#" style="color: inherit; text-decoration: none;">T&eacute;rminos Cl&iacute;nicos</a>
                    <a href="#" style="color: inherit; text-decoration: none;">Farmacovigilancia</a>
                </div>
            </div>
        </footer>
    </form>
</body>
</html>