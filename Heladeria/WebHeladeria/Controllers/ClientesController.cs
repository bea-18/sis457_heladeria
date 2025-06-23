using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using WebHeladeria.Models;

namespace WebHeladeria.Controllers
{
    public class ClientesController : Controller
    {
        private readonly FinalHeladeriaContext _context;

        public ClientesController(FinalHeladeriaContext context)
        {
            _context = context;
        }

        //[HttpGet]
        //public JsonResult Buscar(string dato)
        //{
        //    var cliente = _context.Clientes
        //        .FirstOrDefault(c => c.Nombre.Contains(dato) || c.Nit == dato);

        //    if (cliente != null)
        //    {
        //        return Json(new { id = cliente.Id, nombre = cliente.Nombre });
        //    }

        //    return Json(null);
        //}
        [HttpGet]
        public JsonResult Buscar(string dato)
        {
            var cliente = _context.Clientes
                .FirstOrDefault(c => c.Nombre.Contains(dato) || c.Nit == dato);

            if (cliente != null)
            {
                return Json(new { id = cliente.Id, nombre = cliente.Nombre });
            }

            return Json(null);
        }


        // GET: Clientes
        public async Task<IActionResult> Index()
        {
            return View(await _context.Clientes.ToListAsync());
        }

        // GET: Clientes/Details/5
        public async Task<IActionResult> Details(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var cliente = await _context.Clientes
                .FirstOrDefaultAsync(m => m.Id == id);
            if (cliente == null)
            {
                return NotFound();
            }

            return View(cliente);
        }

        // GET: Clientes/Create
        public IActionResult Create()
        {
            return View();
        }

        // POST: Clientes/Create
        // To protect from overposting attacks, enable the specific properties you want to bind to.
        // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        //public async Task<IActionResult> Create(Cliente cliente)
        //{
        //    if (ModelState.IsValid)
        //    {
        //        _context.Add(cliente);
        //        await _context.SaveChangesAsync();
        //        return RedirectToAction(nameof(Index));
        //    }
        //    return View(cliente);
        //}
        //public async Task<IActionResult> Create(Cliente cliente)
        //{
        //    if (ModelState.IsValid &&
        //        !string.IsNullOrWhiteSpace(cliente.Nombre) &&
        //        !string.IsNullOrWhiteSpace(cliente.Nit) &&
        //        !string.IsNullOrWhiteSpace(cliente.Celular))
        //    {
        //        cliente.UsuarioRegistro = User.Identity?.Name;
        //        cliente.FechaRegistro = DateTime.Now;
        //        cliente.Estado = 1;

        //        _context.Add(cliente);
        //        await _context.SaveChangesAsync();
        //        return RedirectToAction(nameof(Index));
        //    }

        //    return View(cliente);
        //}
        public async Task<IActionResult> Create(Ventum venta)
        {
            if (ModelState.IsValid)
            {
                if (venta.IdTipoPago == 1) // Efectivo
                {
                    venta.MontoCambio = venta.MontoPago - venta.MontoTotal;
                }
                else
                {
                    venta.MontoPago = 0;
                    venta.MontoCambio = 0;
                }

                venta.FechaRegistro = DateTime.Now;
                venta.UsuarioRegistro = User.Identity.Name; // o el nombre del usuario actual

                _context.Add(venta);
                await _context.SaveChangesAsync();
                return RedirectToAction(nameof(Index));
            }

            ViewBag.IdUsuario = new SelectList(_context.Usuarios, "Id", "Usuario", venta.IdUsuario);
            ViewBag.IdCliente = new SelectList(_context.Clientes, "Id", "Nombre", venta.IdCliente);
            ViewBag.IdTipoPago = new SelectList(_context.TipoPagos, "Id", "Descripcion", venta.IdTipoPago);
            return View(venta);
        }

        // GET: Clientes/Edit/5
        public async Task<IActionResult> Edit(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var cliente = await _context.Clientes.FindAsync(id);
            if (cliente == null)
            {
                return NotFound();
            }
            return View(cliente);
        }

        // POST: Clientes/Edit/5
        // To protect from overposting attacks, enable the specific properties you want to bind to.
        // For more details, see http://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(int id, [Bind("Id,Nombre,Nit,Celular,UsuarioRegistro,FechaRegistro,Estado")] Cliente cliente)
        {
            if (id != cliente.Id)
            {
                return NotFound();
            }

            if (ModelState.IsValid)
            {
                try
                {
                    _context.Update(cliente);
                    await _context.SaveChangesAsync();
                }
                catch (DbUpdateConcurrencyException)
                {
                    if (!ClienteExists(cliente.Id))
                    {
                        return NotFound();
                    }
                    else
                    {
                        throw;
                    }
                }
                return RedirectToAction(nameof(Index));
            }
            return View(cliente);
        }

        // GET: Clientes/Delete/5
        public async Task<IActionResult> Delete(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var cliente = await _context.Clientes
                .FirstOrDefaultAsync(m => m.Id == id);
            if (cliente == null)
            {
                return NotFound();
            }

            return View(cliente);
        }

        // POST: Clientes/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(int id)
        {
            var cliente = await _context.Clientes.FindAsync(id);
            if (cliente != null)
            {
                _context.Clientes.Remove(cliente);
            }

            await _context.SaveChangesAsync();
            return RedirectToAction(nameof(Index));
        }

        private bool ClienteExists(int id)
        {
            return _context.Clientes.Any(e => e.Id == id);
        }
    }
}
