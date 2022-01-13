from django.contrib import admin

from .models import *

admin.site.site_title = 'GESTION ECOLE'
admin.site.site_header = 'GESTION ECOLE'


class EnseignantAdmin(admin.ModelAdmin):
    fields = ('nomEns', 'prenomEns', 'grade', 'anneePriseFonction')
    list_display = ('nomEns', 'prenomEns', 'grade', 'anneePriseFonction')


class NiveauAdmin(admin.ModelAdmin):
    fields = ('libNiv', 'nbModules', 'codeParc')
    list_display = ('libNiv', 'nbModules', 'codeParc')


class ParcoursAdmin(admin.ModelAdmin):
    fields = ('codeParc', 'libParc')
    list_display = ('codeParc', 'libParc')


class EtudiantAdmin(admin.ModelAdmin):
    fields = ('nomEtud', 'prenomEtud', 'sexe', 'dateNaissance', 'codeParc')
    list_display = ('nomEtud', 'prenomEtud', 'sexe', 'dateNaissance', 'codeParc')


class InscrireAdmin(admin.ModelAdmin):
    fields = ('numEtu', 'codeNiv', 'anneeIns')
    list_display = ('numEtu', 'codeNiv', 'anneeIns')


class ClasseAdmin(admin.ModelAdmin):
    fields = ('codeClass', 'libClass', 'capacite')
    list_display = ('codeClass', 'libClass', 'capacite')


class EvaluationAdmin(admin.ModelAdmin):
    fields = ('codeEval', 'libEval', 'pourcentage')
    list_display = ('codeEval', 'libEval', 'pourcentage')


class ModuleAdmin(admin.ModelAdmin):
    fields = ('codeMod', 'libMod', 'nbCredit', 'est_requis', 'codeNiv', 'annneeCreation')
    list_display = ('codeMod', 'libMod', 'nbCredit', 'est_requis', 'codeNiv', 'annneeCreation')


class ModuleRequisAdmin(admin.ModelAdmin):
    fields = ('codeMod', 'codePrerequis')
    list_display = ('codeMod', 'codePrerequis')


class DispenserAdmin(admin.ModelAdmin):
    fields = ('numEns', 'codeMod',  'codeclass', 'annneeDisp')
    list_display = ('numEns', 'codeMod', 'codeclass', 'annneeDisp')


class NoterAdmin(admin.ModelAdmin):
    fields = ('numEtu', 'codeMod', 'codeEval', 'note', 'valide', 'dateEval')
    list_display = ('numEtu', 'codeMod', 'codeEval', 'note', 'valide', 'dateEval')


admin.site.register(Parcours, ParcoursAdmin)
admin.site.register(Niveau, NiveauAdmin)
admin.site.register(Etudiant, EtudiantAdmin)
admin.site.register(Inscrire, InscrireAdmin)
admin.site.register(Enseignant, EnseignantAdmin)
admin.site.register(Classe, ClasseAdmin)
admin.site.register(Evaluation, EvaluationAdmin)
admin.site.register(Module, ModuleAdmin)
admin.site.register(ModuleRequis, ModuleRequisAdmin)
admin.site.register(Dispenser, DispenserAdmin)
admin.site.register(Noter, NoterAdmin)
