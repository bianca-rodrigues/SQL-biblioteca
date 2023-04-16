import express from 'express'
import sql from 'mssql'
import { sqlConfig } from '../sql/config.js'

const router = express.Router()

/***************************************
 * GET /editoras
 * Lista todos as editoras
 ***************************************/
router.get('/', (req, res) => {
    try {
        sql.connect(sqlConfig).then(pool => {
            return pool.request()
                .execute('SP_S_BIB_EDITORA')
        }).then(dados => {
            res.status(200).json(dados.recordset)
        }).catch(err => {
            res.status(400).json(err)
        })
    } catch (err) {
        console.error(`Erro ao conectar: ${err.message}`)
    }
})

/***************************************
 * POST /editora
 * Insere uma nova editora
 ***************************************/
router.post('/', (req, res) => {
    sql.connect(sqlConfig).then(pool => {
        const { nome } = req.body
        return pool
            .request()
            .input('NOME', sql.VarChar(100), nome)
            .execute('SP_I_BIB_EDITORA')
    }).then(dados => {
        res.status(200).json(dados.output)
    }).catch(err => {
        res.status(400).json(err.message)
    })
})

/**********************************************
 * PUT /editora
 * Altera uma editora existente
 **********************************************/
router.put("/", (req, res) => {
    sql.connect(sqlConfig).then(pool => {
      const {id, nome} = req.body
          return pool
          .request()
          .input('ID', sql.Int, id)
          .input('NOME', sql.VarChar(50), nome)
          .execute('SP_U_BIB_EDITORA')
        }).then(dados => {
          res.status(200).json('Editora alterado com sucesso!')
      }).catch(err => {
          res.status(400).json(err.message) //bad request
      })
  })

  /**********************************************
 * DELETE /editora/
 * Apaga uma editora pelo id
 **********************************************/
router.delete("/:id", (req, res) => {
    sql.connect(sqlConfig).then(pool => {
      const id = req.params.id
          return pool.request()
          .input('ID', sql.Int, id)
          .execute('SP_D_BIB_EDITORA')
        }).then(dados => {
          res.status(200).json('Editora excluída com sucesso!')
      }).catch(err => {
          res.status(400).json(err.message)
      })
  })

  /**********************************************
 * GET /lvrio
 * Lista uma única editora pelo id
 **********************************************/
router.get("/:id", (req, res) => {
    const id = req.params.id
    try {
        sql.connect(sqlConfig).then(pool => {
            return pool.request()
                .input('FILTRO', sql.Int, id)
                .execute('SP_S_BIB_EDITORA')
        }).then(dados => {
            res.status(200).json(dados.recordset)
        }).catch(err => {
            res.status(400).json(err)
        })
    } catch (err) {
        console.error(err)
    }
})
export default router
