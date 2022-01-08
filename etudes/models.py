# -*- coding: utf-8 -*-
from django.db import models
import datetime


class Parcours(models.Model):
    codeParc = models.CharField(max_length=5, primary_key=True)
    libParc = models.CharField(max_length=100, blank=False)

    def __str__(self):
        return self.libParc

    class Meta:
        db_table = 'PARCOURS'
        verbose_name = 'Parcours'
        verbose_name_plural = 'Parcours'


class Niveau(models.Model):
    codeNiv = models.BigAutoField(primary_key=True)
    libNiv = models.CharField(max_length=20, blank=False)
    nbModules = models.IntegerField(default=0)
    codeParc = models.ForeignKey(Parcours, on_delete=models.CASCADE, blank=False)

    def __str__(self):
        return self.libNiv, self.nbModules, self.codeParc

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
    nomEtu = models.CharField(max_length=30, blank=False)
    prenomEtu = models.CharField(max_length=50, blank=False)
    sexe = models.CharField(max_length=1, choices=SEXE_CHOICES)
    dateNaissance = models.DateField(blank=False)
    codeParc = models.ForeignKey(Parcours, on_delete=models.CASCADE, blank=False)

    def __str__(self):
        return [self.nomEtu, self.prenomEtu, self.sexe, self.codeParc, self.dateNaissance]

    class Meta:
        db_table = 'ETUDIANT'
        verbose_name = 'Etudiant'
        verbose_name_plural = 'Etudiants'


class Inscrire(models.Model):
    date = datetime.datetime.now()
    codeIns = models.BigAutoField(primary_key=True)
    numEtu = models.ForeignKey(Etudiant, on_delete=models.RESTRICT, blank=False)
    codeNiv = models.ForeignKey(Niveau, on_delete=models.RESTRICT, blank=False)
    annneeIns = models.IntegerField(default=date.year)

    def __str__(self):
        return self.codeIns

    class Meta:
        db_table = 'INSCRIRE'
        verbose_name = "Inscrire"
        verbose_name_plural = 'Inscrires'


class Enseignant(models.Model):
    date = datetime.datetime.now()

    numEns = models.BigAutoField(primary_key=True)
    nomEns = models.CharField(max_length=30, blank=False)
    prenomEns = models.CharField(max_length=30, blank=False)
    grade = models.CharField(max_length=25, blank=False)
    annneePriseFonct = models.IntegerField(default=date.year)

    def __str__(self):
        return self.nomEns

    class Meta:
        db_table = 'ENSEIGNANT'
        verbose_name = "Enseignant"
        verbose_name_plural = 'Enseignants'


class Classe(models.Model):
    codeClass = models.CharField(max_length=5, blank=False, primary_key=True)
    libClass = models.CharField(max_length=20, blank=False)
    capacite = models.IntegerField()

    def __str__(self):
        return self.libClass

    class Meta:
        db_table = 'CLASSE'
        verbose_name = "Classe"


class Evaluation(models.Model):
    codeEval = models.CharField(max_length=10, blank=False, primary_key=True)
    libEval = models.CharField(max_length=30, blank=False)
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
    libMod = models.CharField(max_length=20, blank=False)
    nbCredit = models.IntegerField(blank=False)
    est_requis = models.BooleanField(blank=False)
    codeNiv = models.ForeignKey(Niveau, on_delete=models.RESTRICT, blank=False)
    annneeCreation = models.IntegerField(default=date.year)

    def __str__(self):
        return self.libMod

    class Meta:
        db_table = 'MODULE'
        verbose_name = 'Module'
        verbose_name_plural = 'Modules'


class ModulePrerequis(models.Model):
    id = models.BigAutoField(blank=False, primary_key=True)
    codeMod = models.ForeignKey(Module, on_delete=models.RESTRICT, blank=False, related_name='codeModule')
    codePrerequis = models.ForeignKey(Module, on_delete=models.RESTRICT, blank=False, related_name='codeRequis')

    def __str__(self):
        return self.codeMod, self.codePrerequis

    class Meta:
        db_table = 'MODULES_PREREQUIS'
        verbose_name = 'Module requis'
        verbose_name_plural = 'Module requis'


class Dispenser(models.Model):
    date = datetime.datetime.now()

    codeDisp = models.BigAutoField(primary_key=True)
    codeMod = models.ForeignKey(Module, on_delete=models.RESTRICT, blank=False)
    codeclass = models.ForeignKey(Classe, on_delete=models.RESTRICT, blank=False)
    numEns = models.ForeignKey(Enseignant, on_delete=models.RESTRICT, blank=False)
    annneeDisp = models.IntegerField(default=date.year)

    def __str__(self):
        return self.codeMod, self.numEns, self.codeclass

    class Meta:
        db_table = 'DISPENSER'
        verbose_name = 'Dispenser'
        verbose_name_plural = 'Dispenser'


class ModuleEval(models.Model):
    codeModEval = models.BigAutoField(primary_key=True)
    dateEval = models.DateField(blank=False)
    codeMod = models.ForeignKey(Module, on_delete=models.RESTRICT, blank=False)
    codeEval = models.ForeignKey(Evaluation, on_delete=models.RESTRICT, blank=False)

    class Meta:
        db_table = 'MODULE_EVAL'
        verbose_name = 'Module Evaluation'
        verbose_name_plural = 'Module Evaluations'

    def __str__(self):
        return self.codeMod, self.codeEval


class Noter(models.Model):
    codeNote = models.BigAutoField(primary_key=True)
    note = models.FloatField(blank=False, default=range(0, 20))
    valide = models.BooleanField()
    codeModEval = models.ForeignKey(ModuleEval, on_delete=models.RESTRICT, blank=False)
    numEtu = models.ForeignKey(Etudiant, on_delete=models.RESTRICT, blank=False)

    class Meta:
        db_table = 'NOTER'
        verbose_name = 'Noter'
        verbose_name_plural = 'Noter'

    def __str__(self):
        return self.numEtu, self.codeModEval, self.note
