# -*- coding: utf-8 -*-
from django.db import models
import datetime


class Parcours(models.Model):
    codeParc = models.CharField(max_length=5, primary_key=True)
    libParc = models.CharField(max_length=100, blank=False, unique=True)

    def __str__(self):
        return self.libParc

    class Meta:
        db_table = 'PARCOURS'
        verbose_name = 'Parcours'
        verbose_name_plural = 'Parcours'


class Niveau(models.Model):
    codeNiv = models.BigAutoField(primary_key=True, blank=False)
    libNiv = models.CharField(max_length=50, db_column='libNiv',  blank=False, unique=True)
    nbModules = models.IntegerField(default=0, db_column='nbreModule')
    codeParc = models.ForeignKey(Parcours, db_column='codeParc', on_delete=models.CASCADE, blank=False)

    def __str__(self):
        return self.libNiv

    class Meta:
        db_table = 'NIVEAU'
        verbose_name = 'Niveau'
        verbose_name_plural = 'Niveaux'


class Etudiant(models.Model):
    SEXE_CHOICES = (
        ('M', 'Masculin'),
        ('F', 'Féminin'),
    )
    numEtu = models.BigAutoField(primary_key=True)
    nomEtud = models.CharField(max_length=50, blank=False)
    prenomEtud = models.CharField(max_length=50, blank=False)
    sexe = models.CharField(max_length=1, choices=SEXE_CHOICES)
    dateNaissance = models.DateField(blank=False)
    codeParc = models.ForeignKey(Parcours, db_column='codeParc', on_delete=models.CASCADE, blank=False)

    def __str__(self):
        return f"{self.nomEtud} {self.prenomEtud}"

    class Meta:
        db_table = 'ETUDIANT'
        verbose_name = 'Etudiant'
        verbose_name_plural = 'Etudiants'


class Inscrire(models.Model):
    date = datetime.datetime.now()
    Id = models.BigAutoField(primary_key=True, blank=False)
    numEtu = models.ForeignKey(Etudiant, db_column="NumEtu", on_delete=models.RESTRICT, blank=False, unique=True)
    codeNiv = models.ForeignKey(Niveau, db_column="CodeNiv", on_delete=models.RESTRICT, blank=False)
    anneeIns = models.IntegerField(default=date.year)

    def __str__(self):
        return f"{self.numEtu}, {self.codeNiv}, Année: {self.anneeIns}"

    class Meta:
        db_table = 'INSCRIRE'
        verbose_name = "Inscrire"
        # unique_together = ('numEtu', 'codeNiv')
        verbose_name_plural = 'Inscrires'


class Enseignant(models.Model):
    date = datetime.datetime.now()

    numEns = models.BigAutoField(primary_key=True)
    nomEns = models.CharField(max_length=30, blank=False)
    prenomEns = models.CharField(max_length=30, blank=False)
    grade = models.CharField(max_length=25, blank=False)
    anneePriseFonction = models.IntegerField(default=date.year, db_column='anneePriseFonction')

    def __str__(self):
        return f"{self.nomEns} {self.prenomEns}"

    class Meta:
        db_table = 'ENSEIGNANT'
        verbose_name = "Enseignant"
        verbose_name_plural = 'Enseignants'


class Classe(models.Model):
    codeClass = models.CharField(max_length=5, blank=False, primary_key=True)
    libClass = models.CharField(max_length=30, blank=False, unique=True)
    capacite = models.IntegerField()

    def __str__(self):
        return self.libClass

    class Meta:
        db_table = 'CLASSE'
        verbose_name = "Classe"


class Evaluation(models.Model):
    codeEval = models.CharField(max_length=10, blank=False, primary_key=True)
    libEval = models.CharField(max_length=50, blank=False, unique=True)
    pourcentage = models.IntegerField(blank=False, default=range(0, 100))

    def __str__(self):
        return self.libEval

    class Meta:
        db_table = 'EVALUATION'
        verbose_name = 'Evaluation'
        verbose_name_plural = 'Evaluations'


class Module(models.Model):
    date = datetime.datetime.now()

    codeMod = models.CharField(max_length=10, blank=False, primary_key=True)
    libMod = models.CharField(max_length=100, blank=False, unique=True)
    nbCredit = models.IntegerField(blank=False)
    est_requis = models.BooleanField(blank=False)
    codeNiv = models.ForeignKey(Niveau, db_column='codeNiv', on_delete=models.RESTRICT, blank=False)
    annneeCreation = models.IntegerField(default=date.year, db_column='anneeCreation')

    def __str__(self):
        return self.libMod

    class Meta:
        db_table = 'MODULE'
        verbose_name = 'Module'
        verbose_name_plural = 'Modules'


class ModuleRequis(models.Model):
    Id = models.BigAutoField(primary_key=True, blank=False)
    codeMod = models.ForeignKey(Module, db_column='codeMod', on_delete=models.RESTRICT, blank=False,
                                related_name='codeModule')
    codePrerequis = models.ForeignKey(Module, db_column='codeModRequis', on_delete=models.RESTRICT, blank=False,
                                      related_name='codeRequis')

    def __str__(self):
        return f"{self.codeMod}, {self.codePrerequis}"

    class Meta:
        db_table = 'MODULES_REQUIS'
        # que_together = ('codeMod', 'codePrerequis')
        verbose_name = 'Module requis'
        verbose_name_plural = 'Module requis'


class Dispenser(models.Model):
    date = datetime.datetime.now()
    Id = models.BigAutoField(primary_key=True, blank=False)
    codeMod = models.ForeignKey(Module, db_column="codeMod", on_delete=models.RESTRICT, blank=False)
    codeclass = models.ForeignKey(Classe, db_column="codeClass", on_delete=models.RESTRICT, blank=False)
    numEns = models.ForeignKey(Enseignant, db_column="numEns", on_delete=models.RESTRICT, blank=False)
    annneeDisp = models.IntegerField(default=date.year, db_column='anneeDisp')

    def __str__(self):
        return f"{self.numEns}, {self.codeMod}, {self.codeclass}"

    class Meta:
        db_table = 'DISPENSER'
        verbose_name = 'Dispenser'
        # nique_together = ('codeMod', 'codeclass', 'numEns')
        verbose_name_plural = 'Dispenser'


class Noter(models.Model):
    Id = models.BigAutoField(primary_key=True, blank=False)
    numEtu = models.ForeignKey(Etudiant, db_column='numEtu', on_delete=models.RESTRICT)  # Field name
    # made lowercase.
    codeMod = models.ForeignKey(Module, db_column='codeMod', on_delete=models.RESTRICT)  # Field name made lowercase.
    codeEval = models.ForeignKey(Evaluation, db_column='codeEval', on_delete=models.RESTRICT)
    # Field name made lowercase.
    note = models.FloatField(blank=True, null=True)
    valide = models.BooleanField(blank=True, null=True)
    dateEval = models.DateField(db_column='dateEval')  # Field name made lowercase.

    class Meta:
        db_table = 'NOTER'
        verbose_name = 'Noter'
        verbose_name_plural = 'Noter'
        # unique_together = ('numEtud', 'codeMod', 'codeEval')

    def __str__(self):
        return f"{self.numEtu}, {self.codeMod}, Note: {self.note}"
