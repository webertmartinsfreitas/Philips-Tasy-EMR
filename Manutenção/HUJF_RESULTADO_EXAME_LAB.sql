SELECT 
    PP.NR_PRESCRICAO,
    PM.NR_ATENDIMENTO,
    EL.NR_SEQ_APRESENT,
    PP.CD_PROCEDIMENTO,
    OBTER_DESC_EXAME_LAB(EL.NR_SEQ_EXAME,EL.CD_EXAME,PP.CD_PROCEDIMENTO,'') DS_EXAME,
    GEL.DS_GRUPO_EXAME_LAB,
    0 NR_SEQ_PAGINA,
    ELRI.DT_LIBERACAO,
    ELRI.DT_APROVACAO,
    OBTER_NOME_USUARIO(OBTER_USUARIO_LIBERACAO_LAB( ELR.NR_PRESCRICAO, ELRI.NR_SEQ_PRESCR)) ||' - '|| OBTER_DS_COD_PROF(OBTER_PESSOA_FISICA_USUARIO(ELRI.NM_USUARIO_LIBERACAO,'C') ) LIBERADO_POR,
    ELRI.DT_COLETA,
    PP.CD_MATERIAL_EXAME,
    OBTER_HASH_ASSINATURA(OBTER_ASSINATURA_DIG_EXAME_LAB(ELR.NR_PRESCRICAO,ELRI.NR_SEQ_PRESCR)) NR_HASH,
    CASE WHEN OBTER_HASH_ASSINATURA(OBTER_ASSINATURA_DIG_EXAME_LAB(ELR.NR_PRESCRICAO,ELRI.NR_SEQ_PRESCR)) IS NOT NULL THEN ' Este laudo foi assinado digitalmente sob o nro:' END DS_CERTIFICADO,  
    RL.DS_RESULTADO
FROM PRESCR_PROCEDIMENTO PP
INNER JOIN PRESCR_MEDICA PM ON PM.NR_PRESCRICAO = PP.NR_PRESCRICAO
INNER JOIN EXAME_LABORATORIO EL ON EL.NR_SEQ_EXAME = PP.NR_SEQ_EXAME
INNER JOIN GRUPO_EXAME_LAB GEL ON GEL.NR_SEQUENCIA = EL.NR_SEQ_GRUPO
LEFT OUTER JOIN EXAME_LAB_RESULTADO ELR ON ELR.NR_PRESCRICAO = PP.NR_PRESCRICAO
LEFT OUTER JOIN EXAME_LAB_RESULT_ITEM ELRI ON ELRI.NR_SEQ_RESULTADO = ELR.NR_SEQ_RESULTADO AND PP.NR_SEQUENCIA = ELRI.NR_SEQ_PRESCR AND PP.NR_SEQ_EXAME = ELRI.NR_SEQ_EXAME
LEFT OUTER JOIN RESULT_LABORATORIO RL ON PP.NR_PRESCRICAO = RL.NR_PRESCRICAO AND RL.NR_SEQ_PRESCRICAO = PP.NR_SEQUENCIA
WHERE PP.IE_SUSPENSO <> 'S'
AND PM.DT_SUSPENSAO IS NULL
AND 
(
        SELECT
            NVL(MAX(T.NR_SEQ_PAGINA),-1)
        FROM
            RESULT_LABORATORIO_QUEBRA T
        WHERE
            T.NR_SEQ_RESULT_LAB = RL.NR_SEQUENCIA
    ) < 0
